#!/bin/sh

# Check if this commit is tagged

tags="$(git tag --contains)"

if [ ! -z "$tags" ]; then

    # Create a custom keychain
    sudo security create-keychain -p travis ios-build.keychain

    # Make the custom keychain default, so xcodebuild will use it for signing
    sudo security default-keychain -s ios-build.keychain

    # Unlock the keychain
    sudo security unlock-keychain -p travis ios-build.keychain

    # Set keychain timeout to 1 hour for long builds
    sudo security set-keychain-settings -t 3600 -l ~/Library/Keychains/ios-build.keychain

    # Add certificates to keychain and allow codesign to access them
    sudo security import ./apple.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
    sudo security import ./dist.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign

    echo "This will be released to Fabric"

    # Add provisioning profile to xcode

    sudo mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
    uuid=`grep UUID -A1 -a BreakOutBeta.mobileprovision | grep -io "[-A-Z0-9]\{36\}"`
    sudo mv BreakOutBeta.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/$uuid.mobileprovision

    # Build & Archive

    xcodebuild \
        -workspace BreakOut.xcworkspace \
        -scheme BreakOut \
        -destination "generic/platform=iOS" \
        -configuration Release \
        PROVISIONING_PROFILE="$uuid" \
        CODE_SIGN_IDENTITY="iPhone Distribution: Mathias Quintero (KJPP698PR3)" \
        ONLY_ACTIVE_ARCH=NO 'CODE_SIGN_RESOURCE_RULES_PATH=$(SDKROOT)/ResourceRules.plist' \
        archive | xcpretty

    # Run submit

    "Pods/Crashlytics/submit" 1c0980d1b003b77f0ea981400d725dab7fef673b 0fdd77bc7fcb1d472997f39a62c7399a604d22d98dddebb29e0b49f161bbadb1

    # Delete provisioning profile

    sudo rm ~/Library/MobileDevice/Provisioning\ Profiles/$uuid.mobileprovision

    sudo security delete-keychain ios-build.keychain

else
    echo "This will not be released, there is no tag"
fi
