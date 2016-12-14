# Uncomment this line to define a global platform for your project
# platform :ios, '6.0'

target 'BreakOut' do

pod 'SwiftyJSON'
pod 'Sweeft'

pod 'Instabug', '~> 5.1.2'
pod 'Fabric', '~> 1.6.7'
pod 'Crashlytics', '~> 3.7.0'

pod 'Firebase'
pod 'Firebase/Messaging'

# Flurry -> App Analytics (Funnel, ...)
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
pod 'Flurry-iOS-SDK/FlurrySDK', '~> 7.5.2'

# Database
pod 'MagicalRecord', '~> 2.3.2'
pod 'Pantry', :git=> 'https://github.com/andreyz/Pantry.git', :branch => 'swift3'

# Networking
pod 'AFNetworking', '~> 3.0'
pod 'AFOAuth2Manager', '~> 3.0'
pod 'Alamofire', '~> 4.0'

# UI
pod 'SpinKit', '~>1.2.0'
pod 'MBProgressHUD', '~> 0.9.2'
pod 'SlideMenuControllerSwift', '~> 3.0.0'
pod 'LECropPictureViewController', '~> 0.1.2'
pod 'SwiftDate', '~> 4.0'
pod 'StaticDataTableViewController', '~> 2.0'
pod 'GGFullscreenImageViewController', '~> 1.0'

pod 'TouchVisualizer', '~> 2.0.1'

use_frameworks!

pod 'Toaster', '~> 2.0'

pod 'netfox', :git=> 'https://github.com/mathiasquintero/netfox.git'

pod 'ReachabilitySwift', '~> 3'

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
