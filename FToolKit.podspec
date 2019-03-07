Pod::Spec.new do |s|
  s.name                   = 'FToolKit'
  s.version                = '1.1'
  s.description            = 'iOS Debug Tools'
  s.summary                = 'iOS Debug Tools'
  s.homepage               = 'https://github.com/wjmwjmwb/FToolKit'
  s.license                = { :type => 'MIT', :file => 'LICENSE' }
  s.author                 = { 'Four' => 'wjmwjmwb@yeah.net' }
  s.source                 = { :git => 'https://github.com/wjmwjmwb/FToolKit', :tag => s.version.to_s }
  s.ios.deployment_target  = '8.0'
  s.frameworks             = 'Foundation'
  s.source_files           = 'FToolKit/**/*'
  s.requires_arc           = true
  s.dependency 'RealmBrowserKit'
  s.dependency 'FLEX', '~> 2.0'
  s.dependency 'FHHFPSIndicator'

end
