readSourcesWithSetzer()  {
	local _assetPair="$1"
	local _setzerAssetPair="$1"
	_setzerAssetPair="${_setzerAssetPair/\/}"
	_setzerAssetPair="${_setzerAssetPair,,}"
	local _prices

	_prices=$(ETH_RPC_URL="$SETZER_ETH_RPC_URL" \
	  "source-setzer" sources "$_setzerAssetPair" \
		| parallel \
			-j${OMNIA_SOURCE_PARALLEL:-0} \
			--termseq KILL \
			--timeout "$OMNIA_SRC_TIMEOUT" \
			_mapSetzer "$_setzerAssetPair"
	)

	local _price
	local _source
	local _median=$(getMedian $(jq -sr 'add|.[]' <<<"$_prices"))
	verbose "median => $_median"

	jq -cs \
		--arg a "$_assetPair" \
		--argjson m "$_median" '
		{ asset: $a
		, median: $m
		, sources: .|add
		}' <<<"$_prices"
}

_mapSetzer() {
	local _assetPair=$1
	local _source=$2
	local _price
	_price=$(ETH_RPC_URL="$SETZER_ETH_RPC_URL" \
	"source-setzer" price "$_assetPair" "$_source")
	if [[ -n "$_price" && "$_price" =~ ^([1-9][0-9]*([.][0-9]+)?|[0][.][0-9]*[1-9]+[0-9]*)$ ]]; then
		jq -nc \
			--arg s $_source \
			--arg p "$(LANG=POSIX printf %0.10f "$_price")" \
			'{($s):$p}'
	else
		error "$_assetPair price from $_source is $_price"
	fi
}
export -f _mapSetzer

readSourcesWithGofer()   {
	local _output
	_output=$(gofer price --config "$GOFER_CONFIG" --format json "$@")
	verbose "gofer output" "$_output"
	echo "$_output" | jq -c '
		.[]
		| {
			asset: (.base+"/"+.quote),
			median: .price,
			sources: (
				[ ..
				| select(type == "object" and .type == "origin" and .error == null)
				| {(.base+"/"+.quote+"@"+.params.origin): (.price|tostring)}
				]
				| add
			)
		}
	'
}