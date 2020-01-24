
latest_binary_url = https://github.com/oasislabs/oasis-core/releases/download/v20.1.1/oasis-node_20.1.1_linux_amd64.tar.gz
latest_binary_url = https://github.com/oasislabs/oasis-core/releases/download/v20.1.2/oasis-node_20.1.2_linux_amd64.tar.gz

latest_genesis_url = https://github.com/oasislabs/public-testnet-artifacts/releases/download/2020-01-15/genesis.json
latest_genesis_url = https://github.com/oasislabs/public-testnet-artifacts/releases/download/2020-01-23/genesis.json


# Lets start somewhere clean eh?

mkdir -p Oasis && cd Oasis

# I have no idea why the setup documentation distinguishes between
# 'node' and 'server', it's typical bad documentation, creating extra
# complexity where there is none or not explaining properly.

mkdir -m700 -p {entity,node}
mkdir -m700 -p {etc,node,node/entity}

wget $latest_binary_url
wget $latest_genesis_url -O etc/genesis.json

tar zxfv oasis-node_*_linux_amd64.tar.gz

GENESIS_FILE_PATH=$PWD/etc/genesis.json

cd node/entity

../../oasis-node registry entity init

cd ../

cat entity/entity.json | json_pp

curl https://extreme-ip-lookup.com/json/

STATIC_IP=66.181.2.210 # CP1
STATIC_IP=66.181.2.211 # CP2
STATIC_IP=210.216.165.11 # Genome
STATIC_IP=210.216.165.21

../oasis-node registry node init \
  --signer file \
  --signer.dir $PWD/entity \
  --node.consensus_address $STATIC_IP:26656 \
  --node.is_self_signed \
  --node.role validator

../oasis-node registry entity update \
  --signer.dir $PWD/entity \
  --entity.node.descriptor node_genesis.json

cat entity/entity.json | json_pp


cd ../

chmod -R 600 *.pem



echo "
datadir: $PWD/node

log:
  level:
    default: debug
    tendermint: warn
    tendermint/context: error
  format: JSON

genesis:
  file: $PWD/etc/genesis.json

worker:
  registration:
    entity: $PWD/node/entity/entity.json

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
" > etc/config.yml



## FFS, talk about crappy setup instructions!
chmod -R go-r,go-w,go-x ./


./oasis-node --config $PWD/etc/config.yml &> log-${date}.log &

./oasis-node registry entity list -a unix:$PWD/node/internal.sock

./oasis-node \
    -a unix:$PWD/node/internal.sock \
    control is-synced \
    && echo "You are synced" || echo "You are not synced"

cat entity/entity.json | json_pp
cat entity/entity.json | json_pp
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

