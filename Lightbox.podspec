Pod::Spec.new do |s|
  s.name             = "Lightbox"
  s.summary          = "A short description of Lightbox."
  s.version          = "1.0.0"
  s.homepage         = "https://github.com/hyperoslo/Lightbox"
  s.license          = 'MIT'
  s.author           = { "Hyper Interaktiv AS" => "ios@hyper.no" }
  s.source           = { :git => "https://github.com/hyperoslo/Lightbox.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/hyperoslo'
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'Source/**/*'
  s.ios.resource = 'Resources/Lightbox.bundle'

  s.frameworks = 'UIKit', 'AVFoundation', 'AVKit'
  s.dependency 'Hue'
  
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }
end
