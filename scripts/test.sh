#!/bin/sh
set -ev
xcodebuild test -project MultipartDataBuilder.xcodeproj -scheme iOS -sdk iphonesimulator -destination platform='iOS Simulator',OS=9.0,name='iPhone 5s'
