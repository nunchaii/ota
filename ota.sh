#!/bin/bash
set -e
VERSION=$1
OUT=~/Infinity/out/target/product/spes
ZIP=$(ls -t $OUT/[Ii]nfinity*.zip | head -1)
NAME=$(basename "$ZIP")
SIZE=$(stat -c%s "$ZIP")
SHA=$(sha256sum "$ZIP" | cut -d' ' -f1)
DATE=$(grep -m1 ro.build.date.utc $OUT/system/build.prop | cut -d= -f2)

gh release create "$VERSION" "$ZIP" -R nunchaii/ota --notes "InfinityX $VERSION" \
  || gh release upload "$VERSION" "$ZIP" -R nunchaii/ota --clobber

rm -rf ~/ota && git clone https://github.com/nunchaii/ota.git ~/ota
cd ~/ota
cat > spes.json <<EOF
{"response":[{"datetime":$DATE,"filename":"$NAME","id":"$SHA","romtype":"UNOFFICIAL","size":$SIZE,"url":"https://github.com/nunchaii/ota/releases/download/$VERSION/$NAME","version":"$VERSION"}]}
EOF
cp changelog.txt "${NAME%.zip}.txt"
git add . && git commit -m "spes $VERSION" && git push
