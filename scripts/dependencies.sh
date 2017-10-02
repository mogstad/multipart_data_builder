#!/bin/sh

curl -O -L https://github.com/Carthage/Carthage/releases/download/0.25.0/Carthage.pkg
sudo installer -pkg Carthage.pkg -target /

carthage bootstrap --use-ssh --platform ios
