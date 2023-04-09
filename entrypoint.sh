#!/bin/sh
set -eu

GETH_DATA_DIR=/data
GETH_CHAINDATA_DIR=$GETH_DATA_DIR/geth/chaindata
GETH_KEYSTORE_DIR=$GETH_DATA_DIR/keystore

[ -f "$GETH_DATA_DIR/alloc-address" ] && ALLOC_ADDRESS_WITHOUT_0X=$(cat "$GETH_DATA_DIR/alloc-address")

if [ ! -d "$GETH_KEYSTORE_DIR" ]; then
    echo -n "$ALLOC_ADDRESS_PRIVATE_KEY" >"$GETH_DATA_DIR/private-key"
    echo -n "${ALLOC_ADDRESS_PRIVATE_KEY_PASSWORD:-seaverse}" > "$GETH_DATA_DIR/password"
    ALLOC_ADDRESS_WITHOUT_0X=$(geth account import \
        --datadir="$GETH_DATA_DIR" \
        --password="$GETH_DATA_DIR/password" \
        "$GETH_DATA_DIR/private-key" | grep -oE '[[:xdigit:]]{40}')
    echo -n "$ALLOC_ADDRESS_WITHOUT_0X" >"$GETH_DATA_DIR/alloc-address"
fi

if [ ! -d "$GETH_CHAINDATA_DIR" ]; then
    sed "s/\${CHAIN_ID}/$CHAIN_ID/g; s/\${ALLOC_ADDRESS_WITHOUT_0X}/$ALLOC_ADDRESS_WITHOUT_0X/g" /genesis.json.template > /genesis.json
    geth init --datadir="$GETH_DATA_DIR" /genesis.json
fi

exec geth \
  --datadir="$GETH_DATA_DIR" \
  --allow-insecure-unlock \
  --unlock="$ALLOC_ADDRESS_WITHOUT_0X" \
  --password="$GETH_DATA_DIR/password" \
  --mine --miner.etherbase="$ALLOC_ADDRESS_WITHOUT_0X"\
  --networkid="$CHAIN_ID" --nodiscover --port=30303 --maxpeers=3 \
  --http --http.addr=0.0.0.0 --http.port=8545 \
  --http.api=debug,net,eth,shh,web3,txpool \
  --http.corsdomain='*' --http.vhosts='*' \
  --ws --ws.addr=0.0.0.0 --ws.port=8546 \
  --ws.api=eth,net,web3,network,debug,txpool \
  --graphql \
  --graphql.corsdomain='*' --graphql.vhosts='*' \
  --syncmode=full --gcmode=archive \
  > "$GETH_DATA_DIR/geth.log" 2>&1
