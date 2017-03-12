#!/bin/sh

# Check if this commit is tagged

tags="$(git tag --contains)"

if [ ! -z "$tags" ]; then

    echo "This will be released to Fabric"

    # Add provisioning profile to xcode

    sudo mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
    uuid=`grep UUID -A1 -a BreakOutBeta.mobileprovision | grep -io "[-A-Z0-9]\{36\}"`
    sudo mv BreakOutBeta.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/$uuid.mobileprovision

    # Build & Archive

    xcodebuild -workspace BreakOut.xcworkspace -scheme BreakOut -destination "generic/platform=iOS" -configuration Release ONLY_ACTIVE_ARCH=NO 'CODE_SIGN_RESOURCE_RULES_PATH=$(SDKROOT)/ResourceRules.plist' archive | xcpretty

    # Run submit

    "Pods/Crashlytics/submit" 1c0980d1b003b77f0ea981400d725dab7fef673b 0fdd77bc7fcb1d472997f39a62c7399a604d22d98dddebb29e0b49f161bbadb1

    # Delete provisioning profile

    rm ~/Library/MobileDevice/Provisioning\ Profiles/$uuid.mobileprovision

else
    echo "This will not be released, there is no tag"
fi
