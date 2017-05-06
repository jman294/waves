#!/usr/bin/env bash

GAME="waves"

# Make .love file
cd ../src/
zip -9 -r ${GAME}.love *
cd ../build/love
cp ../../src/${GAME}.love .

# Make 32 and 64 bit .exe files
cd ../win32
cat love.exe ../love/${GAME}.love > bin/${GAME}.exe
zip -r -9 bin/${GAME}.zip -j *
cd ../win64
cat love.exe ../love/${GAME}.love > bin/${GAME}.exe
zip -r -9 bin/${GAME}.zip -j *

# Make Mac app
GAME_IDENTIFIER="waves"
GAME_NAME="waves"
cd ../macos
rm -r bin/${GAME}.app
cp -r love.app bin/${GAME}.app
cp ../love/${GAME}.love bin/${GAME}.app/Contents/Resources/
cp usethisone.plist bin/${GAME}.app/Contents/Info.plist
sed -i "s/GAME_NAME/$GAME_NAME/g" bin/${GAME}.app/Contents/Info.plist
sed -i "s/GAME_IDENTIFIER/$GAME_IDENTIFIER/g" bin/${GAME}.app/Contents/Info.plist
cd bin/
zip -y -9 -r ${GAME}_osx waves.app
