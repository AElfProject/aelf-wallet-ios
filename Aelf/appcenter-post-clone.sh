#!/bin/bash
git clone https://github.com/AElfProject/aelf-wallet-ios.git Pods-only
cd Pods-only
git checkout pods-only
mv Pods ../
cd ../
brew install autoconf automake libtool
echo "Uninstalling all CocoaPods versions"
sudo gem uninstall cocoapods --all --executables
COCOAPODS_VER=`sed -n -e 's/^COCOAPODS: \([0-9.]*\)/\1/p' Podfile.lock`
echo "Installing CocoaPods version $COCOAPODS_VER"
sudo gem install cocoapods
app_version=`cat AelfApp.xcodeproj/project.pbxproj | grep MARKETING_VERSION |  awk -F"=|;| "  '{ print $4 }' | head -1`
echo $app_version
