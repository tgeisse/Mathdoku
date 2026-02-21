# Uncomment the next line to define a global platform for your project
platform :ios, '16.0'

target 'Mathdoku' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Mathdoku
  pod 'Firebase/Core'
#  pod 'Firebase/AdMob'
  pod 'Google-Mobile-Ads-SDK'
  pod 'Firebase/Database'
  pod 'SwiftyStoreKit'
  pod 'RealmSwift'
#  pod 'PromiseKit', '~> 6.8'
  pod 'SwiftyUserDefaults'
  pod 'Bugsnag'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 12.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end
  end
end
