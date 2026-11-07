#!/bin/bash
set -e
VERSION=$1
EXTERNAL_URL=$2     # optional: direct download link if you host the zip elsewhere
OUT=~/infinity/out/target/product/spes
ZIP=$(ls -t $OUT/*Infinity*.zip | head -1)
NAME=$(basename "$ZIP")
SIZE=$(stat -c%s "$ZIP")
MD5=$(md5sum "$ZIP" | cut -d' ' -f1)
DATE=$(grep -m1 ro.build.date.utc $OUT/system/build.prop | cut -d= -f2)

if [ -n "$EXTERNAL_URL" ]; then
  URL="$EXTERNAL_URL"
else
  gh release create "$VERSION" "$ZIP" -R nunchaii/ota --notes "InfinityX $VERSION spes" \
    || gh release upload "$VERSION" "$ZIP" -R nunchaii/ota --clobber
  URL="https://github.com/nunchaii/ota/releases/download/$VERSION/$NAME"
fi

rm -rf ~/ota && git clone https://github.com/nunchaii/ota.git ~/ota
cd ~/ota
cat > spes.json <<EOF
{
	"response": [
		{
			"filename": "$NAME",
			"download": "$URL",
			"timestamp": $DATE,
			"md5": "$MD5",
			"size": $SIZE,
			"version": "$VERSION"
		}
	]
}
EOF
cp changelog.txt "${NAME%.zip}.txt"
git add . && git commit -m "spes $VERSION" && git push
