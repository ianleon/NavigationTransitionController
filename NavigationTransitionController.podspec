#
# Be sure to run `pod lib lint NavigationTransitionController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NavigationTransitionController'
  s.version          = '0.0.1'
  s.summary          = 'Designed by Nanogram, Inc. in New York'
  s.description      = 'UINavigationController subclass that simplifies interactive transition animations when presenting or dismissing view controllers on iOS.'
  s.homepage         = 'https://github.com/Nanogram-Inc/NavigationTransitionController'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'HackShitUp' => 'josh.m.choi@gmail.com' }
  s.source           = { :git => 'https://github.com/HackShitUp/NavigationTransitionController.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.source_files = 'Classes/**/*.swift'
  s.swift_version = '5.0'
  s.platforms =  {
      "ios": "13.0"
  }
end
