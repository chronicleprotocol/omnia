_mapSetzer() {
	local _assetPair="$1"
	local _source="$2"

	[[ -z $_assetPair || -z $_source ]] \
	&& error "bad _mapSetzer() request" "asset=$_assetPair" "source=$_source" \
	&& return 1

	# shellcheck disable=SC2155
	local _price=$(setzer price "$_assetPair" "$_source")
	if [[ -n "$_price" && "$_price" =~ ^([1-9][0-9]*([.][0-9]+)?|[0][.][0-9]*[1-9]+[0-9]*)$ ]]; then
		jq -nc \
			--arg s "$_assetPair@$_source" \
			--arg p "$(LC_ALL=POSIX printf %0.10f "$_price")" \
			'{($s):$p}'
	else
		error "failed to get asset price" "asset=$_assetPair" "source=$_source"
#		echo >&2 "{\"level\":\"error\",\"msg\":\"Failed to get asset price\",\"asset\":\"$_assetPair\",\"source\":\"$_source\",\"time\":\"$(date "+%s")\"}"
	fi
}
#export -f _mapSetzer

readSourcesWithSetzer()  {
	local _assetPair="$1"
	local _setzerAssetPair="$1"
	_setzerAssetPair="${_setzerAssetPair/\/}"
	_setzerAssetPair="${_setzerAssetPair,,}"

	# shellcheck disable=SC2155
	local _prices
	_prices=$(setzer sources "$_setzerAssetPair" \
	| while IFS= read -r _src; do _mapSetzer "$_setzerAssetPair" "$_src"; done)

	# shellcheck disable=SC2155
	local _median
	_median=$(jq 'add|tonumber' <<<"$_prices" \
	| jq -s 'sort | if length == 0 then null elif length % 2 == 0 then (.[length/2] + .[length/2-1])/2 else .[length/2|floor] end')

	local _output
	_output="$(jq -cs \
		--arg a "$_assetPair" \
		--argjson m "$_median" '
		{ asset: $a
		, median: $m
		, sources: .|add
		}' <<<"$_prices")"

	verbose --raw "setzer [price]" "$_output"
	echo "$_output"
}

readSourcesWithGofer() {
	gofer price --config "$GOFER_CONFIG" --format ndjson "$@" \
	2> >(STDERR_DATA="$(cat)"; [[ -z "$STDERR_DATA" ]] || error "gofer [stderr]" "$STDERR_DATA") \
	| jq -c '{
				asset: (.base+"/"+.quote),
				median: .price,
				sources: (
					[ ..
					| select(type == "object" and .type == "origin" and .error == null)
					| {(.base+"/"+.quote+"@"+.params.origin): (.price|tostring)}
					]
					| add
				)
			}' | tee >(_data="$(cat)"; verbose --raw "gofer [price]" "$(jq -sc <<<"$_data")") \
	|| error --list "Failed to get prices from gofer" "app=gofer" "config=$GOFER_CONFIG" "$@"
}
