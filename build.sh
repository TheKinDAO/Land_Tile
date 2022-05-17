#!/bin/bash

# Fail on error and echo every command
set -ex
cd "`dirname $0`"

export NEAR_ENV=local
export RUSTFLAGS='-C link-arg=-s'
cargo build --all --target wasm32-unknown-unknown --release
cp target/wasm32-unknown-unknown/release/*.wasm ./out/main.wasm

echo "See ./setup.sh and ft/src/lib.rs"
echo "This script is untested, so exiting for now..."
exit 0

case "$2" in
    test)
        export NEAR_ENV=""
        export master="$1"  # agnucius.testnet
        export accountId="land_tile.$master"
        near delete $accountId $master
        near create-account $accountId --masterAccount $master
        echo "Deploying to TESTnet on subaccount $accountId"
        ;;
    main)
        export NEAR_ENV="mainnet"
        export master="$1"  # suicunga.near
        export accountId="land_tile.near"
        echo "near delete $accountId $master"
        echo "Create account at https://wallet.near.org/create"
        echo "Deploying to MAINnet on account $accountId"
        ;;
    *)
        echo "Arg1: username"
        echo "Arg2: 'main' or 'test'"
        ;;
esac

export NEAR_ENV=local
export NEAR_ENV=mainnet

# Build
yarn && yarn test:deploy


# Deploy
near deploy --accountId $accountId

# NFT init
near call --accountId $accountId $accountId new_default_meta '{"owner_id":"'$accountId'", "treasury_id":"'$master'"}'

# NFT create series
near call --accountId $accountId $accountId nft_create_series '{"token_series_id":"test1", "creator_id":"'$accountId'","token_metadata":{"title":"3810 Thomas Rd, Miranda, CA 95553","media":"bafybeidzcan4nzcz7sczs4yzyxly4galgygnbjewipj6haco4kffoqpkiy", "reference":"bafybeicg4ss7qh5odijfn2eogizuxkrdh3zlv4eftcmgnljwu7dm64uwji", "copies": 152283},"price":"1000000000000000000000000"}' --depositYocto 8540000000000000000000

# NFT create series with royalty
near call --accountId $accountId $accountId nft_create_series '{"token_series_id":"1","creator_id":"alice.test.near","token_metadata":{"title":"Naruto Shippuden ch.2: Menolong sasuke","media":"bafybeidzcan4nzcz7sczs4yzyxly4galgygnbjewipj6haco4kffoqpkiy", "reference":"bafybeicg4ss7qh5odijfn2eogizuxkrdh3zlv4eftcmgnljwu7dm64uwji", "copies": 100},"price":"1000000000000000000000000", "royalty":{"alice.test.near": 1000}}' --depositYocto 8540000000000000000000

# NFT transfer with payout
near call --accountId $accountId $accountId nft_transfer_payout '{"token_id":"10:1","receiver_id":"comic1.test.near","approval_id":"0","balance":"1000000000000000000000000", "max_len_payout": 10}' --depositYocto 1

# NFT buy
near call --accountId $accountId $accountId nft_buy '{"token_series_id":"1","receiver_id":"$accountId"}' --depositYocto 1011280000000000000000000

# NFT mint series (Creator only)
near call --accountId alice.test.near $accountId nft_mint '{"token_series_id":"1","receiver_id":"$accountId"}' --depositYocto 11280000000000000000000

# NFT transfer
near call --accountId $accountId $accountId nft_transfer '{"token_id":"1:1","receiver_id":"comic1.test.near"}' --depositYocto 1

# NFT set series non mintable (Creator only)
near call --accountId alice.test.near $accountId nft_set_series_non_mintable '{"token_series_id":"1"}' --depositYocto 1

# NFT set series price (Creator only)
near call --accountId alice.test.near $accountId nft_set_series_price '{"token_series_id":"1", "price": "2000000000000000000000000"}' --depositYocto 1

# NFT set series not for sale (Creator only)
near call --accountId alice.test.near $accountId nft_set_series_price '{"token_series_id":"1"}' --depositYocto 1

# NFT burn
near call --accountId $accountId $accountId nft_burn '{"token_id":"1:1"}' --depositYocto 1

# NFT approve
near call --accountId alice.test.near $accountId nft_approve '{"token_id":"1:10","account_id":"marketplace.test.near","msg":"{\"price\":\"3000000000000000000000000\",\"ft_token_id\":\"near\"}"}' --depositYocto 1320000000000000000000

# export RUSTFLAGS='-C link-arg=-s'
# cargo build --all --target wasm32-unknown-unknown --release
# cp target/wasm32-unknown-unknown/release/*.wasm ./res/

# ## Test
# cargo test -- --nocapture

# ## Deploy
# near login
# near deploy --wasmFile res/paras_nft_contract.wasm --accountId $accountId

# # source neardev/dev-account.env
# # see ./nft/src/lib.rs
# near call $accountId new_default_meta '{"owner_id": "'$accountId'"}' --accountId $accountId

# near view $accountId nft_metadata

# near call $accountId nft_mint '{"token_id": "0", "receiver_id": "'$accountId'", "token_metadata": { "title": "Olympus Mons", "description": "Tallest mountain in charted solar system", "media": "https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/Olympus_Mons_alt.jpg/1024px-Olympus_Mons_alt.jpg", "copies": 1}}' --accountId $accountId --deposit 0.1

# near call $accountId nft_transfer '{"token_id": "0", "receiver_id": "'$master'", "memo": "transfer ownership"}' --accountId $accountId --depositYocto 1

# near view $accountId nft_tokens_for_owner '{"account_id": "'$master'"}'  # "from_index": "0", "limit": 100}'
