#!/bin/sh

# Check if this commit is tagged

tags="$(git tag --contains)"

if [ ! -z "$tags" ]; then

    # Create a custom keychain
    security create-keychain -p travis ios-build.keychain

    # Unlock the keychain
    security unlock-keychain -p travis ios-build.keychain

    # Set keychain timeout to 1 hour for long builds
    security set-keychain-settings -t 3600 -l ~/Library/Keychains/ios-build.keychain

    # Add certificates to keychain and allow codesign to access them
    security import ./apple.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
    security import ./dist.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign

    # Set keychain to default
    security default-keychain -s ios-build.keychain

    # Add provisioning profile to xcode

    sudo mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
    UUID=`grep UUID -A1 -a BreakOutBeta.mobileprovision | grep -io "[-A-Z0-9]\{36\}"`
    sudo mv BreakOutBeta.mobileprovision \
        $HOME/Library/MobileDevice/Provisioning\ Profiles/$UUID.mobileprovision

    DEVELOPER_NAME="iPhone Distribution: Mathias Quintero (KJPP698PR3)"
    APP_NAME="BreakOut"
    PROVISIONING_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$UUID.mobileprovision"

    echo "This will be released to Fabric"

    echo "First do a clean build"

    xcodebuild -workspace BreakOut.xcworkspace \
        -scheme BreakOut \
        -sdk "iphoneos" \
        -destination "generic/platform=iOS" \
        -configuration Release \
        archive | xcpretty

    # Run submit

    "Pods/Crashlytics/submit" 1c0980d1b003b77f0ea981400d725dab7fef673b \
        0fdd77bc7fcb1d472997f39a62c7399a604d22d98dddebb29e0b49f161bbadb1 \
        -notesPath "Built by travis for $tags" \
        -groupAliases Development

    # Delete provisioning profile

    sudo rm -f ~/Library/MobileDevice/Provisioning\ Profiles/*

    sudo security delete-keychain ios-build.keychain

else
    echo "This will not be released, there is no tag"
fi
