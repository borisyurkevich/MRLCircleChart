#
# Be sure to run `pod lib lint MRLCircleChart.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name    = 'MRLCircleChart'
  s.version = '0.5.1'
  s.summary = 'Small, far from perfect, and very opinionated pie-chart view written in Swift. '

  s.description = <<-DESC
  MRLCircleChart is a small pie/circle chart UI component written in Swift. Aims to take care of most of the work for you (just pass in a data source and configure the view) at the expense of customizability. It's a work in progress written for a secret project.
                       DESC
  s.homepage = 'https://github.com/mlisik/MRLCircleChart.git'
  s.author   = { 'mlisik' => 'lisik.marek@gmail.com' }
  s.source   = { git: 'https://github.com/mlisik/MRLCircleChart.git', tag: s.version.to_s }
  s.license = { type: 'MIT', file: 'LICENSE' }

  s.platform     = :ios, '8.0'

  s.source_files = 'Source/*.swift'
end
