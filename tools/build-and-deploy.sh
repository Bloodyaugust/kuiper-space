#!/bin/sh

# set -e

which butler

echo "Checking application versions..."
echo "-----------------------------"
cat ~/.local/share/godot/templates/3.2.stable/version.txt
godot --version
butler -V
echo "-----------------------------"

mkdir build/
mkdir build/linux/
mkdir build/osx/
mkdir build/win/

echo "EXPORTING FOR LINUX"
echo "-----------------------------"
godot --export "Linux/X11" build/linux/kuiper-space.x86_64 -v
echo "EXPORTING FOR OSX"
echo "-----------------------------"
godot --export "Mac OSX" build/osx/kuiper-space.dmg -v
echo "EXPORTING FOR WINDOZE"
echo "-----------------------------"
godot --export "Windows Desktop" build/win/kuiper-space.exe -v
echo "-----------------------------"

echo "CHANGING FILETYPE AND CHMOD EXECUTABLE FOR OSX"
echo "-----------------------------"
cd build/osx/
mv kuiper-space.dmg kuiper-space-osx-alpha.zip
unzip kuiper-space-osx-alpha.zip
rm kuiper-space-osx-alpha.zip
chmod +x kuiper-space.app/Contents/MacOS/kuiper-space
zip -r kuiper-space-osx-alpha.zip kuiper-space.app
rm -rf kuiper-space.app
cd ../../

ls -al
ls -al build/
ls -al build/linux/
ls -al build/osx/
ls -al build/win/

echo "ZIPPING FOR WINDOZE"
echo "-----------------------------"
cd build/win/
zip -r kuiper-space-win-alpha.zip kuiper-space.exe kuiper-space.pck
rm -r kuiper-space.exe kuiper-space.pck
cd ../../

echo "ZIPPING FOR LINUX"
echo "-----------------------------"
cd build/linux/
zip -r kuiper-space-linux-alpha.zip kuiper-space.x86_64 kuiper-space.pck
rm -r kuiper-space.x86_64 kuiper-space.pck
cd ../../

echo "Logging in to Butler"
echo "-----------------------------"
butler login

echo "Pushing builds with Butler"
echo "-----------------------------"
butler push build/linux/ synsugarstudio/kuiper-space:linux-alpha
butler push build/osx/ synsugarstudio/kuiper-space:osx-alpha
butler push build/win/ synsugarstudio/kuiper-space:win-alpha
