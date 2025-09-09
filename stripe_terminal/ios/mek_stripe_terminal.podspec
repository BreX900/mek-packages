#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint stripe_terminal.podspec` to validate before publishing.
#

require 'yaml'

pubspec = YAML.load_file(File.join('..', 'pubspec.yaml'))

Pod::Spec.new do |s|
  s.name             = pubspec['name']
  s.version          = '1.0.0'
  s.summary          = pubspec['description']
  s.description      = pubspec['description']
  s.homepage         = pubspec['homepage']
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'BreX900' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '14.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.dependency 'StripeTerminal', '~> 4.6.0'
end
