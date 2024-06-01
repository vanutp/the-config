#!/usr/bin/env bash
set -e
SERVER_NAME="$1"
SFER=servers/sfer
OUT_DIR=./out
SCRIPT_FILENAME=build-sfer-"$SERVER_NAME".sh
IMAGE_FILENAME=sfer-"$SERVER_NAME".raw
if [[ -z $SERVER_NAME ]]; then
  echo Specify a server to build sfer for
  echo Note: this script must be ran in the root flake directory
  exit 1
fi
if [[ -e "$OUT_DIR/main.raw" ]]; then
  echo main.raw exists in $OUT_DIR, do something!!
  exit 1
fi
echo Building sfer for $SERVER_NAME
set -x

cp servers/"$SERVER_NAME"/system/hardware-configuration.nix $SFER/hardware-configuration.nix
cp servers/"$SERVER_NAME"/system/disko.nix $SFER/disko.nix
cp servers/"$SERVER_NAME"/vars.nix $SFER/vars.nix
git add $SFER/hardware-configuration.nix $SFER/disko.nix $SFER/vars.nix

mkdir -p "$OUT_DIR"
nix build .#nixosConfigurations.sfer.config.system.build.diskoImagesScript --out-link "$OUT_DIR/$SCRIPT_FILENAME"
pushd "$OUT_DIR"
./"$SCRIPT_FILENAME" --build-memory 8192
mv main.raw "$IMAGE_FILENAME"
zstd --rm "$IMAGE_FILENAME"
popd

rm $SFER/hardware-configuration.nix $SFER/disko.nix $SFER/vars.nix
rm "$OUT_DIR/$SCRIPT_FILENAME"

set +x

echo Done! Built to $OUT_DIR/$IMAGE_FILENAME.zst
