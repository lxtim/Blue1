# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'Blue' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Blue

    pod 'Firebase/Core'
    pod 'Firebase/Auth'
    pod 'Firebase/Database'
    pod 'Firebase/Storage'
    pod 'TPKeyboardAvoidingSwift'
    pod 'MRProgress'
    pod 'UITextView+Placeholder'
    pod 'SDWebImage'
    pod 'VGPlayer'
    pod 'ScrollableSegmentedControl'
#    pod 'BMPlayer'
    pod 'YTBarButtonItemWithBadge'
    pod 'CropViewController'
    pod 'SJSegmentedScrollView', ‘1.3.6'
#    
  target 'BlueTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'BlueUITests' do
    inherit! :search_paths
    # Pods for testing
  end
  
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end

    
