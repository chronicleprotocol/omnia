pullOracleTime () {
	local _assetPair="$1"
	local _address
	_address=$(getOracleContract "$_assetPair")
	if ! [[ "$_address" =~ ^(0x){1}[0-9a-fA-F]{40}$ ]]; then
		error "Error - Invalid Oracle contract"
		return 1
	fi

	timeout -s9 10 ethereum --rpc-url "$ETH_RPC_URL" call "$_address" "age()(uint32)"
}

pullOracleQuorum () {
	local _assetPair="$1"
	local _address
	_address=$(getOracleContract "$_assetPair")
	if ! [[ "$_address" =~ ^(0x){1}[0-9a-fA-F]{40}$ ]]; then
		error "Error - Invalid Oracle contract"
		return 1
	fi

	timeout -s9 10 ethereum --rpc-url "$ETH_RPC_URL" call "$_address" "bar()(uint256)"
}

pullOraclePrice () {
	local _assetPair="$1"
	local _address
	local _rawStorage
	_address=$(getOracleContract "$_assetPair")
	if ! [[ "$_address" =~ ^(0x){1}[0-9a-fA-F]{40}$ ]]; then
			error "Error - Invalid Oracle contract"
			return 1
	fi

	_rawStorage=$(timeout -s9 10 ethereum --rpc-url "$ETH_RPC_URL" storage "$_address" 0x1)

	[[ "${#_rawStorage}" -ne 66 ]] && error "oracle contract storage query failed" && return

	ethereum --from-wei "$(ethereum --to-dec "${_rawStorage:34:32}")"
}

pushOraclePrice () {
		local _assetPair="$1"
		local _oracleContract
		
		# Using custom gas pricing strategy
		local _fees
		_fees=($(getGasPrice))

		_oracleContract=$(getOracleContract "$_assetPair")
		if ! [[ "$_oracleContract" =~ ^(0x){1}[0-9a-fA-F]{40}$ ]]; then
		  error "Error - Invalid Oracle contract"
		  return 1
		fi
		log "Sending tx..."
		tx=$(ethereum --rpc-url "$ETH_RPC_URL" --gas-price "${_fees[0]}" --prio-fee "${_fees[1]}" send --async "$_oracleContract" 'poke(uint256[] memory,uint256[] memory,uint8[] memory,bytes32[] memory,bytes32[] memory)' \
				"[$(join "${allPrices[@]}")]" \
				"[$(join "${allTimes[@]}")]" \
				"[$(join "${allV[@]}")]" \
				"[$(join "${allR[@]}")]" \
				"[$(join "${allS[@]}")]")
		
		_status="$(timeout -s9 60 ethereum --rpc-url "$ETH_RPC_URL" receipt "$tx" status)"
		_gasUsed="$(timeout -s9 60 ethereum --rpc-url "$ETH_RPC_URL" receipt "$tx" gasUsed)"
		
		# Monitoring node helper JSON
		verbose "Transaction receipt" "tx=$tx" "maxGasPrice=${_fees[0]}" "prioFee=${_fees[1]}" "gasUsed=$_gasUsed" "status=$_status"
}
