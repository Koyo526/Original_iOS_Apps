# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'OriginalSNS' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for OriginalSNS
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Nuke'
  pod 'PKHUD', '~> 5.0'
  pod 'FirebaseUI'
  pod 'NYXImagesKit'
  pod 'Cosmos', '~> 23.0'
  pod 'SwiftDate', '4.5.0'
  pod 'UITextView+Placeholder'
  pod 'Kingfisher'
  pod ‘NCMB’, :git => ‘https://github.com/NIFTYCloud-mbaas/ncmb_ios.git’, :branch => ‘develop’
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings.delete('CODE_SIGNING_ALLOWED')
              config.build_settings.delete('CODE_SIGNING_REQUIRED')
          end
      end
      installer.pods_project.build_configurations.each do |config|
          config.build_settings.delete('CODE_SIGNING_ALLOWED')
          config.build_settings.delete('CODE_SIGNING_REQUIRED')
      end
  end
  target 'OriginalSNSTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'OriginalSNSUITests' do
    # Pods for testing
  end

end
