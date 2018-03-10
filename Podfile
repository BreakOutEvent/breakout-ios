source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target 'BreakOut' do

    # Push Notifications
    pod 'OneSignal', '>= 2.5.2', '< 3.0'

    # Model and API Calls
    pod 'Sweeft', '~> 0.15.2'

    # Analytics
    pod 'Fabric', '~> 1.6.7'
    pod 'Crashlytics', '~> 3.7.0'

    # Database
    pod 'Pantry' # Want to remove this

    # UI
    pod 'SpinKit', '~> 1.2.0' # I still have no idea why we have this
    pod 'SlideMenuControllerSwift', '~> 3.0.0'
    pod 'StaticDataTableViewController', '~> 2.0'
    pod 'DTPhotoViewerController'

    # Chat UI
    pod 'NMessenger’, '1.0.79'
    pod 'KSTokenView', '~> 3.1'
    pod 'MDGroupAvatarView', :git => 'https://github.com/mathiasquintero/MDGroupAvatarView.git'


    # Team UI
    pod 'Pageboy', '~> 0.4.11'
    pod 'MXParallaxHeader'

    target 'BreakOutTests' do
        inherit! :search_paths
    end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.2'
    end
  end
end
