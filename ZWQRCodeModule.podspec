#
# Be sure to run `pod lib lint ZWQRCodeModule.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    
  s.name             = 'ZWQRCodeModule'
  s.version          = '0.0.1'
  s.summary          = '个人Swfit版本的扫码库ZWQRCodeModule.'
  s.description      = <<-DESC
TODO: 个人Swfit版本的扫码库ZWQRCodeModule，提供扫码和识别图片中二维码，以及基于扫码的其他功能。
                       DESC
  s.homepage         = 'https://github.com/x-zzwang/ZWQRCodeModule'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'x-zzwang' => '17628048484@163.com' }
  s.source           = { :git => 'https://github.com/x-zzwang/ZWQRCodeModule.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'ZWQRCodeModule/Classes/*.swift'
  s.resource_bundles = {
      'ZWQRCodeModule' => ['ZWQRCodeModule/Assets/*.png']
  }
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Masonry'
  
end
