#!/bin/bash

set -e

name="$1"
nameLowercase="$2"

echo Launcher sha256sum
sha256sum build/libs/"$name".jar

cmake -S liblauncher -B liblauncher/buildaarch64 -A ARM64
cmake --build liblauncher/buildaarch64 --config Release

pushd native
cmake -B build-aarch64 -A ARM64
cmake --build build-aarch64 --config Release
popd

source .jdk-versions.sh

rm -rf build/win-aarch64
mkdir -p build/win-aarch64

if ! [ -f win-aarch64_jre.zip ] ; then
    curl -Lo win-aarch64_jre.zip $WIN_AARCH64_LINK
fi

echo "$WIN_AARCH64_CHKSUM win-aarch64_jre.zip" | sha256sum -c

cp native/build-aarch64/src/Release/"$name".exe build/win-aarch64/
cp build/libs/"$name".jar build/win-aarch64/
cp build/packr/win-aarch64-config.json build/win-aarch64/config.json
cp liblauncher/buildaarch64/Release/launcher_aarch64.dll build/win-aarch64/

unzip win-aarch64_jre.zip
mv $WIN_AARCH64_RELEASE-jre build/win-aarch64/jre

echo "$name".exe aarch64 sha256sum
sha256sum build/win-aarch64/"$name".exe

dumpbin //HEADERS build/win-aarch64/"$name".exe

# We use the filtered iss file
iscc build/filtered-resources/runeliteaarch64.iss