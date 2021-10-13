#get id of scuttlebot peer
getFeedId() {
	ssb-server whoami 2> /dev/null | jq -r '.id'
}