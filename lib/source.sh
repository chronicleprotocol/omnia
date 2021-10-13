_mapSetzer() {
	local _assetPair=$1
	local _source=$2
	local _price
	_price=$("source-setzer" price "$_assetPair" "$_source")
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

readSourcesWithSetzer()  {
	local _assetPair="$1"
	local _setzerAssetPair="$1"
	_setzerAssetPair="${_setzerAssetPair/\/}"
	_setzerAssetPair="${_setzerAssetPair,,}"
	local _prices

	_prices=$("source-setzer" sources "$_setzerAssetPair" \
		| parallel \
			-j${OMNIA_SOURCE_PARALLEL:-0} \
			--termseq KILL \
			--timeout "$OMNIA_SRC_TIMEOUT" \
			_mapSetzer "$_setzerAssetPair"
	)

	local _price
	local _median
	_median=$(getMedian "$(jq -sr 'add|.[]' <<<"$_prices")")

	local _output
	_output="$(jq -cs \
		--arg a "$_assetPair" \
		--argjson m "$_median" '
		{ asset: $a
		, median: $m
		, sources: .|add
		}' <<<"$_prices")"

	verbose --list "setzer price" "$_output"
	echo "$_output"
}

readSourcesWithGofer()   {
	local _output
	_output="$(jq -c '
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
	' <<<"$(gofer price --config "$GOFER_CONFIG" --format json "$@")")"

	verbose --list "gofer price" "$_output"
	echo "$_output"
}