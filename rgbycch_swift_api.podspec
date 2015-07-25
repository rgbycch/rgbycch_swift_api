#
# Be sure to run `pod lib lint rgbycch_swift_api.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "rgbycch_swift_api"
  s.version          = "0.1.0"
  s.summary          = "Swift API client for the rgbycch API"
  s.description      = <<-DESC
                       Swift API client for the rgbycch API. See the README.md file for installation instructions.
                       DESC
  s.homepage         = "https://github.com/rgbycch/rgbycch_swift_api"
  s.license          = 'MIT'
  s.author           = { "seanoshea" => "oshea.ie@gmail.com" }
  s.source           = { :git => "https://github.com/rgbycch/rgbycch_swift_api.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'rgbycch_swift_api' => ['Pod/Assets/*.png']
  }
end
