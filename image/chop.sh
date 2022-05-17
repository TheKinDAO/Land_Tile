token_id=0
store=agnucius.testnet

# near delete $accountId $master
# near create-account $accountId --masterAccount $master
# near deploy --wasmFile res/non_fungible_token.wasm --accountId $accountId

# convert Mbig.png -crop "22x22" \
#    -set filename:tile "%[fx:page.x/22+1]x%[fx:page.y/22+1]" \
#    +repage +adjoin "Miranda_%[filename:tile].png"

# gm convert Miranda.crop.png -geometry 1000% Miranda.crop.big.png
# gm convert Miranda.crop.big.png Miranda.crop.big.mpc
# (* (/ 8240 18) (/ 6450 18))
# but `gm convert`, discards last row and last column,
# so we get (* 357 456) = 162792

[[ -d tile ]] || mkdir tile

for ((Y=0, ystep=18, yend=ystep-1; yend < 8240; Y+=ystep, yend+=ystep)); do
    row=$(printf "%03d" $((Y/18)))
    row_dir="tile/row_${row}"
    [[ -d $row_dir ]] || mkdir $row_dir
    for ((X=0, xstep=18, xend=xstep-1; xend < 6450; X+=xstep, xend+=xstep)); do
        pixel=$(printf "%03dx%03d" $((X/18)) $((Y/18)))
        output="${row_dir}/Miranda_${pixel}.png"
        echo $output
        [[ -f $output ]] || gm convert Miranda.crop.big.mpc -crop "${xstep}x${ystep}+${X}+${Y}" $output
        # near call $accountId nft_mint '{"token_id": "'$token_id'", "receiver_id": "'$store'", "token_metadata": { "title": "'$pixel' of 3810 Thomas Rd, Miranda, CA 95553", "description": "40 Acres in beautiful Salmon Creek with home and several outbuildings. Main home is 1700 sq ft, two bedroom 1 bathroom; needs some TLC. Mother in law unit, large workshop, 2 car garage, 1500 sq ft metal building, 2 extra outbuildings and bunk house are all extras on the one of a kind property. Property is gated and very private with panoramic views of the surrounding mountains. Several garden areas, established water system, well and spring water, small pond and several storage tanks on site. Everything you need to make a great homestead.", "media": "https://assets.landwatch.com/resizedimages/559/0/h/80/1-3982249549", "copies": 1}}' --accountId $accountId --deposit 0.1
        # let "token_id=token_id+1"
    done
done
