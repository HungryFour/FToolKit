# Uncomment the next line to define a global platform for your project
 platform :ios, '9.0'

target 'FToolKitDemo' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!

  # Pods for FToolKitDemo
     pod 'FToolKit', :path => '.'
     pod 'FLEX', '~> 2.0'
     pod 'MLeaksFinder'
     pod 'RealmBrowserKit'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
        end
    end
end

