#!/bin/bash
## XBMC: Remotely Start Playing a Media File From the Command Line Using the JSON API

## Configure your XBMC RPC details here
XBMC_HOST=192.168.1.1
XBMC_PORT=8080
XBMC_USER=xbmc
XBMC_PASS=xbmc

ID=$1
if [ "$ID" == "" ];
then
  echo "Syntax $0 <http://example.com/full/path/file.[mp4|avi|etc]>"
  exit
fi

if echo $ID | grep "facebook"; then
  ID=$(curl -s "$ID" |sed -n 's/.*_src_no_ratelimit":"\([^"]*\)".*/\1/p' | sed 's/\\\//\//g')
fi

function xbmc_req {
  curl -s -i -X POST --header "Content-Type: application/json" -d "$1" http://$XBMC_USER:$XBMC_PASS@$XBMC_HOST:$XBMC_PORT/jsonrpc 
}

echo -n "Opening video id $ID on $XBMC_HOST ..."
xbmc_req '{"jsonrpc": "2.0", "method": "Playlist.Clear", "params":{"playlistid":1}, "id": 1}';
xbmc_req '{"jsonrpc": "2.0", "method": "Playlist.Add", "params":{"playlistid":1, "item" :{ "file" : "'$ID'"}}, "id" : 1}';
xbmc_req '{"jsonrpc": "2.0", "method": "Player.Open", "params":{"item":{"playlistid":1, "position" : 0}}, "id": 1}';
echo " done."
