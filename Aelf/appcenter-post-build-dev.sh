#!/usr/bin/env bash
sudo gem install fir-cli
fir p $APPCENTER_OUTPUT_DIRECTORY/$APP_FILE -T $FIR_TOKEN
