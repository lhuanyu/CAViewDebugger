Pod::Spec.new do |s|
  s.name               = "CAViewDebugger"
  s.version            = "0.0.2"
  s.summary            = "A lightweight on-device View Hierarchy Debugger(like Xcode) based on Core Animation."
  s.homepage           = "https://github.com/lhuanyu/CAViewDebugger"
  s.license            = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { 'lhuanyu' => 'lhuany@gmail.com' }
  s.source             = { :git => 'https://github.com/lhuanyu/CAViewDebugger.git', :tag => s.version.to_s }
  s.platform           = :ios, "10.0"
  s.swift_version      = '4.2'
  s.source_files       = "CAViewDebugger/ViewDebugger/*.{h,m,swift}"
  s.resources          = "CAViewDebugger/ViewDebugger/*.xcassets"
end
