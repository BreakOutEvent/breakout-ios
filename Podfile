# Uncomment this line to define a global platform for your project
# platform :ios, '6.0'

target 'BreakOut' do

# Push Notifications
pod 'OneSignal', '>= 2.5.2', '< 3.0'

# Model and API Calls
pod 'Sweeft', '~> 0.6'

# Analytics
pod 'Fabric', '~> 1.6.7'
pod 'Crashlytics', '~> 3.7.0'

pod 'Firebase'
pod 'Firebase/Messaging'

# Flurry -> App Analytics (Funnel, ...)
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
pod 'Flurry-iOS-SDK/FlurrySDK', '~> 7.5.2' # Thinking about removing it...

# Database
pod 'Pantry'

# Networking
pod 'Alamofire', '~> 4.0'

# UI
pod 'SpinKit', '~> 1.2.0'
pod 'MBProgressHUD', '~> 0.9.2'
pod 'SlideMenuControllerSwift', '~> 3.0.0'
pod 'StaticDataTableViewController', '~> 2.0'
pod 'DTPhotoViewerController'
pod 'TouchVisualizer', '~> 2.0.1'


pod 'NMessenger'
pod 'KSTokenView', '~> 3.1'
pod 'MDGroupAvatarView', :git => 'https://github.com/mathiasquintero/MDGroupAvatarView.git'


# Team UI
pod 'Pageboy', '~> 0.4.11'
pod 'MXParallaxHeader'

use_frameworks!

# Will soon be removed
pod 'Toaster', '~> 2.0'

# Image Caching
pod 'SDWebImage', '~>3.7'

end

target 'BreakOutTests' do

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
