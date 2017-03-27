Pod::Spec.new do |s|
  s.name             = "HYNetworking"
  s.version          = "0.7"
  s.summary          = "HYNetworking"
  s.description      = "Network Framework Use AFNetworking For HuangYe Team."

  s.homepage         = "https://github.com/fangyuxi/HYNetworking"
  s.license          = 'MIT'
  s.author           = { "fangyuxi" => "xcoder.fang@gmail.com" }
  s.source           = { :git => "https://github.com/fangyuxi/HYNetworking.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/*.{h,m}'
  s.dependency "AFNetworking"
  s.dependency 'HYDBCache'
end
