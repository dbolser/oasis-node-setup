
mkdir -p Build/Oasis

cd Build/Oasis

wget https://github.com/oasislabs/oasis-core/releases/download/v20.1.1/oasis-node_20.1.1_linux_amd64.tar.gz

tar zxfv oasis-node_20.1.1_linux_amd64.tar.gz

wget https://github.com/oasislabs/public-testnet-artifacts/releases/download/2020-01-15/genesis.json

mkdir -m700 -p {entity,node}

GENESIS_FILE_PATH=$PWD/genesis.json

cd entity/

../oasis-node registry entity init

cat entity.json | json_pp

cd ../node/

curl https://extreme-ip-lookup.com/json/

STATIC_IP=66.181.2.210 # CP1
STATIC_IP=66.181.2.211 # CP2
STATIC_IP=210.216.165.11 # Genome
STATIC_IP=210.216.165.21

../oasis-node registry node init \
  --signer file \
  --signer.dir $PWD/../entity \
  --node.consensus_address $STATIC_IP:26656 \
  --node.is_self_signed \
  --node.role validator

../oasis-node registry entity update \
  --signer.dir $PWD/../entity \
  --entity.node.descriptor node_genesis.json

cat ../entity/entity.json | json_pp


### SERVER FFS

#wget https://github.com/oasislabs/oasis-core/releases/download/v20.1.1/oasis-node_20.1.1_linux_amd64.tar.gz

#tar zxfv oasis-node_20.1.1_linux_amd64.tar.gz

cd ../

mkdir -m700 -p {etc,node,node/entity}

cd node
#scp 66.181.2.210:Build/Oasis/oasis-node/node/* ./
#chmod -R 600 *.pem

cd entity/

#scp 66.181.2.210:Build/Oasis/oasis-node/entity/entity.json  ./
cp ../../entity/entity.json ./

cd ../../etc/

wget https://github.com/oasislabs/public-testnet-artifacts/releases/download/2020-01-15/genesis.json

echo "
datadir: /BiO/Access/home/dmb/Build/Oasis/node

log:
  level:
    default: debug
    tendermint: warn
    tendermint/context: error
  format: JSON

genesis:
  file: /BiO/Access/home/dmb/Build/Oasis/etc/genesis.json

worker:
  registration:
    entity: /BiO/Access/home/dmb/Build/Oasis/node/entity/entity.json

consensus:
  validator: true

tendermint:
  abci:
    prune:
      strategy: keep_n
      num_kept: 86400

  core:
    listen_address: tcp://0.0.0.0:26656
    external_address: tcp://$STATIC_IP:26656

  db:
    backend: badger

  debug:
    addr_book_lenient: false

  seed:
    - 'D14B9192C94F437E9FA92A755D3CC0341F2E87CF@34.82.86.53:26656'
" > config.yml

cd ../

chmod -R go-r,go-w,go-x ./

./oasis-node --config $PWD/etc/config.yml

./oasis-node registry entity list -a unix:$PWD/node/internal.sock

cat entity/entity.json | json_pp

https://oasisfoundation.typeform.com/to/dlcekq







## Update fuckery

HEIGHT_TO_DUMP=93000

./oasis-node genesis dump \
	     -a unix:$PWD/node/internal.sock \
	     --genesis.file $PWD/etc/upgrade-dump.json \
	     --height $HEIGHT_TO_DUMP

./oasis-node \
    -a unix:$PWD/node/internal.sock \
    control shutdown

./oasis-node unsafe-reset \
	     --datadir=$PWD/node \
	     --log.level info

wget https://github.com/oasislabs/oasis-core/releases/download/v20.1.2/oasis-node_20.1.2_linux_amd64.tar.gz

tar zxfv oasis-node_20.1.2_linux_amd64.tar.gz

wget https://github.com/oasislabs/public-testnet-artifacts/releases/download/2020-01-23/genesis.json -O etc/genesis.json
sha1sum etc/genesis.json 
#bcd8eb7cee74969dd7446ec9ac43be2042164c20  etc/genesis.json

./oasis-node --config $PWD/etc/config.yml
 


./oasis-node \
    -a unix:$PWD/node/internal.sock \
    control is-synced \
    && echo "You are synced" || echo "You are not synced"


cat entity/entity.json | json_pp





./oasis-node -h |less

# Oasis Node

# Usage:
#   oasis-node [flags]
#   oasis-node [command]

# Available Commands:
#   consensus    consensus backend commands
#   control      node control interface utilities
#   debug        debug utilities
#   genesis      genesis block utilities
#   help         Help about any command
#   ias          IAS related utilities
#   identity     identity interface utilities
#   keymanager   keymanager utilities
#   registry     registry backend utilities
#   signer       signer backend utilities
#   stake        stake token backend utilities
#   storage      storage services and utilities
#   unsafe-reset reset the node state (UNSAFE)
