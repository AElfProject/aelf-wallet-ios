#!/bin/bash
brew install autoconf automake libtool
echo "Installing CocoaPods"
sudo gem install cocoapods
pod repo update && pod install