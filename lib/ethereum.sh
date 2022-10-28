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

jameshackMosmHash () { # NOTE this one creates uint32 for zzz
    local wat wad zzz

    wat=$(seth --to-bytes32 "$(seth --from-ascii "$1")")
    wad=$2 # already in bytes32 format
    zzz=$(echo "$3" | sed 's/0\{56\}//g') # truncate to uint32
    hexcat=$(echo "$wad$zzz$wat" | sed 's/0x//g')
    log "jameshack wat $wat"
    log "jameshack wad $wad"
    log "jameshack zzz $zzz"
    seth keccak 0x"$hexcat"
}

jameshackMosm () {
	log "jameshackMosm($1 $2 $3)"
	log "jameshack price ${allPrices[0]}"
	log "jameshack time ${allTimes[0]}"
	log "jameshack v ${allV[0]}"
	log "jameshack r ${allR[0]}"
	log "jameshack s ${allS[0]}"
	hash=$(jameshackMosmHash ETHUSD "${allPrices[0]}" "${allTimes[0]}")
	log "jameshackMosmHash: $hash"

	sig=$(ethsign msg --from "$ETH_FROM" --data "$hash" --passphrase-file "$ETH_PASSWORD")
	res=$(sed 's/^0x//' <<< "$sig")
	r=${res:0:64}
	s=${res:64:64}
	v=${res:128:2}
	v=$(seth --to-word "0x$v")

	log "jameshack ETH_FROM=$ETH_FROM (make sure to lift())"
	log "jameshack new v $v"
	log "jameshack new r $r"
	log "jameshack new s $s"


    zzz=$(echo "${allTimes[0]}" | sed 's/0\{56\}//g') # truncate to uint32
	log "jameshack zzz $zzz"

	tx=$(ethereum --rpc-url "$ETH_RPC_URL" --gas-price "$2" --prio-fee "$3" send --async "$1" 'poke(uint256[] memory,uint32[] memory,uint8[] memory,bytes32[] memory,bytes32[] memory)' \
		"[${allPrices[0]}]" \
		"[$zzz]" \
		"[$v]" \
		"[0x$r]" \
		"[0x$s]")

	_status="$(timeout -s9 60 ethereum --rpc-url "$ETH_RPC_URL" receipt "$tx" status)"
	_gasUsed="$(timeout -s9 60 ethereum --rpc-url "$ETH_RPC_URL" receipt "$tx" gasUsed)"

	# Monitoring node helper JSON
	verbose "Transaction receipt" "tx=$tx" "maxGasPrice=${_fees[0]}" "prioFee=${_fees[1]}" "gasUsed=$_gasUsed" "status=$_status"
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
		if [ "$_oracleContract" = "0x50B19f34595bfF59977e3058AC0ff7f729Fdc67a" ]; then
			jameshackMosm "$_oracleContract" "${_fees[0]}" "${_fees[1]}"
		else
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
		fi
}
