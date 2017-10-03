Pod::Spec.new do |s|
  s.name             = "Lightbox"
  s.summary          = "A a convenient and easy to use image viewer for your iOS app, packed with all the features you expect"
  s.version          = "2.0.0"
  s.homepage         = "https://github.com/hyperoslo/Lightbox"
  s.license          = 'MIT'
  s.author           = { "Hyper Interaktiv AS" => "ios@hyper.no" }
  s.source           = { :git => "https://github.com/hyperoslo/Lightbox.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/hyperoslo'
  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.source_files = 'Source/**/*'
  s.ios.resource = 'Resources/Lightbox.bundle'

  s.frameworks = 'UIKit', 'AVFoundation', 'AVKit'
  s.dependency 'Hue', '~> 3.0'
  s.dependency 'Imaginary', '~> 3.0'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
end
