#
# Be sure to run `pod lib lint MABasicKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MABasicKit'
  s.version          = '0.1.0'
  s.summary          = 'iOS基础库'
  s.description      = <<-DESC
iOS基础库
                       DESC

  s.homepage         = 'https://github.com/Admin/MABasicKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'maqihan' => '1250307429@qq.com' }
  s.source           = { :git => 'https://github.com/Admin/MABasicKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'MABasicKit/Classes/MABasicKit.h'
  
  # s.resource_bundles = {
  #   'MABasicKit' => ['MABasicKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
#  s.subspec 'UI' do |ss|
#
#    ss.subspec 'ExpendListView' do |sss|
#      sss.source_files = 'MABasicKit/Classes/ExpendListView/*.{h,m}'
#    end
#
#  end
  
  s.subspec 'Utils' do |ss|
    ss.source_files = 'MABasicKit/Classes/Utils/*.{h,m}'
  end

end
