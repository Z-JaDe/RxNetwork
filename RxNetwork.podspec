Pod::Spec.new do |s|
    s.name             = "RxNetwork"
    s.version          = "1.0.0"
    s.summary          = "响应式网络请求"
    s.description      = <<-DESC
    Based on RxSwift, Alamofire implementation
    DESC
    s.homepage         = "https://github.com/Z-JaDe"
    s.license          = "MIT"
    s.author           = { "ZJaDe" => "zjade@outlook.com" }
    s.source           = { :git => "https://github.com/Z-JaDe/RxNetwork.git", :tag => s.version.to_s }
    
    s.requires_arc          = true
    
    s.ios.deployment_target = '10.0'
    s.frameworks            = "Foundation"
    s.swift_version         = "5.0"

    s.source_files          = "Sources/**/*.{swift}"

    s.dependency "RxSwift"
    s.dependency "Alamofire"
end
