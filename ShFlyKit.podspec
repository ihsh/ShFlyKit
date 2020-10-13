

Pod::Spec.new do |spec|
  #基础配置
  spec.name         = "ShFlyKit"
  spec.version      = "1.0.6"
  spec.summary      = "A framework that is often used in enterprise development"
  spec.description  = <<-DESC
                      A framework that is often used in enterprise developments
                      DESC

  spec.homepage     = "https://github.com/ihsh/ShFlyKit"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'ihsh' => '957929697@qq.com' }
  spec.source       = { :git => 'https://github.com/ihsh/ShFlyKit.git', :tag => spec.version.to_s }
  spec.ios.deployment_target = '10.0'
  #swift版本
  spec.swift_versions = '4.0'
  spec.pod_target_xcconfig = {
    'ENABLE_BITCODE' => 'NO',
    'CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF' => 'NO',
    'OTHER_LDFLAGS' => '-ObjC',
    'LIBRARY_SEARCH_PATHS' => ['$(inherited)']
  }
  #其他配置
  spec.libraries = "c++"
  spec.static_framework = true
  #全局依赖
#  spec.dependency 'Bugly'
  spec.dependency 'Masonry'
  spec.dependency 'YYModel'
  spec.dependency 'SDWebImage'
  spec.dependency 'FMDB'
  spec.dependency 'AFNetworking'
  #依赖系统库
  spec.frameworks = "UIKit"
  
  
  
  #基础库
  spec.subspec 'Base' do |sp|
        sp.source_files = 'ShFlyKit/Classes/Base/**/*'
  end
  
  #图表
  spec.subspec 'Chart' do |sp|
        sp.source_files = 'ShFlyKit/Classes/Chart/**/*'
        sp.dependency 'ShFlyKit/Base'
  end

  #多媒体
  spec.subspec 'Media' do |sp|
        sp.source_files = 'ShFlyKit/Classes/Media/**/*'
        sp.dependency 'ShFlyKit/Base'
  end
#
#  #网络请求
#  spec.subspec 'Network' do |sp|
#        sp.source_files = 'ShFlyKit/Classes/Network/**/*'
#        sp.dependency 'ShFlyKit/Base'
#  end
#
#  #网络直连
#  spec.subspec 'Server' do |sp|
#        sp.source_files = 'ShFlyKit/Classes/Server/**/*'
#        sp.dependency 'ShFlyKit/Base'
#  end
   
  #图形图像
  spec.subspec 'Graphics' do |sp|
        sp.source_files = 'ShFlyKit/Classes/Graphics/**/*'
        sp.dependency 'ShFlyKit/Base'
        sp.dependency 'ShFlyKit/Media'
#        sp.dependency 'AipOcrSdk'
        sp.resource_bundles = {
            'Graphics' => ['ShFlyKit/Assets/Graphics/**/*']
        }
  end
  
  #UI组件
  spec.subspec 'Components' do |sp|
        sp.source_files = 'ShFlyKit/Classes/Components/**/*'
        sp.dependency 'ShFlyKit/Base'
        sp.dependency 'ShFlyKit/Media'
        sp.dependency 'ShFlyKit/Graphics'
#        sp.dependency 'GT3Captcha'
        sp.resource_bundles = {
            'Components' => ['ShFlyKit/Assets/Components/**/*']
        }
  end

  #分享
  spec.subspec 'Share' do |sp|
        sp.source_files = 'ShFlyKit/Classes/Share/**/*.{h,m,swift}'
        sp.public_header_files = 'ShFlyKit/Classes/Share/**/*.h'
        sp.dependency 'ShFlyKit/Base'
        sp.frameworks = 'SystemConfiguration'
        sp.libraries = "c++", "z","sqlite3"
        
        sp.ios.vendored_frameworks = 'ShFlyKit/Classes/Share/**/*.framework'
        sp.vendored_libraries = 'ShFlyKit/Classes/Share/**/*.a'
  end

  #支付
  spec.subspec 'Pay' do |sp|
        sp.source_files = 'ShFlyKit/Classes/Pay/**/*.{h,m,swift}'
        sp.public_header_files = 'ShFlyKit/Classes/Pay/**/*.h'
        sp.dependency 'ShFlyKit/Base'
        sp.dependency 'ShFlyKit/Share'
        sp.dependency 'ShFlyKit/Graphics'
        sp.libraries = "c++", "z","sqlite3"
        sp.frameworks = 'CFNetwork', 'Security', 'CoreTelephony', 'SystemConfiguration', 'CoreMotion', 'QuartzCore', 'CoreText', 'CoreGraphics', 'WebKit' ,'PassKit'
        sp.ios.vendored_frameworks = 'ShFlyKit/Classes/Pay/SDKs/Alipay/AlipaySDK.framework'
        sp.resources = 'ShFlyKit/Classes/Pay/SDKs/Alipay/AlipaySDK.bundle'
        sp.vendored_libraries = 'ShFlyKit/Classes/Pay/**/*.a'
        sp.resource_bundles = {
            'Pay' => ['ShFlyKit/Assets/Pay/**/*']
        }
        
  end
  
#  spec.subspec 'Map' do |sp|
#        sp.dependency 'ShFlyKit/Base'
#        sp.subspec 'General' do |gesp|
#            gesp.source_files = 'ShFlyKit/Classes/Map/General/**/*'
#        end
#        
#        sp.subspec 'Amap' do |asp|
#            asp.source_files = 'ShFlyKit/Classes/Map/Amap/**/*'
#            asp.dependency 'ShFlyKit/Map/General'
#            asp.dependency 'ShFlyKit/Components'
#            asp.dependency 'AMapSearch'
#            asp.dependency 'AMapLocation'
#            asp.dependency 'AMapNavi'
#        end
  
#        sp.subspec 'BaiduMap' do |bsp|
#            bsp.source_files = 'ShFlyKit/Classes/Map/BaiduMap/**/*'
#            bsp.dependency 'BaiduMapKit'
#            bsp.dependency 'BMKLocationKit'
#            bsp.libraries = 'sqlite3', 'c++'
#            bsp.resource_bundles = {
#                'BaiduMap' => ['ShFlyKit/Classes/Map/BaiduMap/Resources/*']
#            }
#        end
#  end
  
  
end
