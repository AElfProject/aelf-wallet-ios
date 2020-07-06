#!/usr/bin/env bash
git clone https://github.com/AElfProject/aelf-wallet-ios.git Pods
cd Pods/Pods
git checkout pods-only
cd ../../
brew install autoconf automake libtool
echo "Uninstalling all CocoaPods versions"
sudo gem uninstall cocoapods --all --executables
COCOAPODS_VER=`sed -n -e 's/^COCOAPODS: \([0-9.]*\)/\1/p' Podfile.lock`
echo "Installing CocoaPods version $COCOAPODS_VER"
sudo gem install cocoapods
