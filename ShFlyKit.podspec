

Pod::Spec.new do |spec|
  spec.name         = "ShFlyKit"
  spec.version      = "1.0.5"
  spec.summary      = "A framework that is often used in enterprise development"
  spec.description  = <<-DESC
                      A framework that is often used in enterprise development
                      DESC

  spec.homepage     = "https://github.com/ihsh/ShFlyKit"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'ihsh' => '957929697@qq.com' }
  spec.source       = { :git => 'https://github.com/ihsh/ShFlyKit.git', :tag => spec.version.to_s }
  spec.ios.deployment_target = '10.0'
  #swift版本
  spec.swift_versions = '4.0'
  spec.pod_target_xcconfig = {
    'ENABLE_BITCODE' => 'NO'
  }
  spec.static_framework = true
  #全局依赖
  spec.dependency 'Bugly'
  spec.dependency 'Masonry'
  spec.dependency 'YYModel'
  spec.dependency 'SDWebImage'
  spec.dependency 'FMDB'
  spec.dependency 'AFNetworking'
  
  #基础库
  spec.subspec 'Base' do |sp|
        sp.source_files = 'ShFlyKit/Classes/Base/**/*'
  end
  
  #图表
  spec.subspec 'Chart' do |sp|
        sp.source_files = 'ShFlyKit/Classes/Chart/**/*'
        sp.dependency 'ShFlyKit/Base'
  end
  #图形图像
  spec.subspec 'Graphics' do |sp|
        sp.source_files = 'ShFlyKit/Classes/Graphics/**/*'
        sp.dependency 'ShFlyKit/Base'
        sp.dependency 'ShFlyKit/Media'
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
        sp.resource_bundles = {
            'Components' => ['ShFlyKit/Assets/Components/**/*']
        }
  end

#spec.subspec 'Share' do |sp|
#      sp.source_files = 'ShFlyKit/Classes/Share/**/*'
#      sp.dependency 'ShFlyKit/Base'
#      sp.ios.vendored_frameworks = 'ShFlyKit/Classes/Share/**/*.framework'
#      sp.vendored_libraries = 'ShFlyKit/Classes/Share/**/*.a'
#end

#  spec.subspec 'Pay' do |sp|
#        sp.source_files = 'ShFlyKit/Classes/Pay/**/*'
#        sp.dependency 'ShFlyKit/Base'
#        sp.ios.vendored_frameworks = 'ShFlyKit/Classes/Pay/**/*.framework'
#        sp.vendored_libraries = 'ShFlyKit/Classes/Pay/**/*.a'
#        sp.resource_bundles = {
#            'Pay' => ['ShFlyKit/Assets/Pay/**/*']
#        }
#  end
  
  #多媒体
  spec.subspec 'Media' do |sp|
        sp.source_files = 'ShFlyKit/Classes/Media/**/*'
        sp.dependency 'ShFlyKit/Base'
  end
  #网络请求
  spec.subspec 'Network' do |sp|
        sp.source_files = 'ShFlyKit/Classes/Network/**/*'
        sp.dependency 'ShFlyKit/Base'
  end
  
  spec.subspec 'Server' do |sp|
        sp.source_files = 'ShFlyKit/Classes/Server/**/*'
        sp.dependency 'ShFlyKit/Base'
  end

  spec.frameworks = "UIKit"
  
  #  spec.subspec 'Map' do |sp|
  #      sp.source_files = 'SHKit/Classes/Map/**/*'
  #      sp.dependency 'ShFlyKit/Base'
  #
  #
  #         sp.subspec 'Amap' do |asp|
  #           asp.source_files = 'SHKit/Classes/Map/Amap/**/*.{h,m}'
  ##           asp.public_header_files = 'SHKit/Classes/Map/Amap/*.h'
  #           asp.ios.vendored_frameworks = 'SHKit/Classes/Map/Amap/SDKs/*.framework'
  #           asp.libraries = 'z', 'c++'
  #           asp.frameworks = 'GLKit', 'CoreLocation', 'SystemConfiguration', 'CoreGraphics', 'Security', 'CoreTelephony','ExternalAccessory'
  #           asp.resource_bundles = {
  #               'AMap' => ['SHKit/Classes/Map/Amap/Resources/*']
  #           }
  #           asp.dependency 'ShFlyKit/Base'
  #           asp.pod_target_xcconfig = {
  #               'OTHER_LDFLAGS' => '-ObjC'
  #           }
  #         end
  #
  #         sp.subspec 'BaiduMap' do |bsp|
  #           bsp.source_files = 'SHKit/Classes/Map/BaiduMap/**/*.{h,m}'
  ##           bsp.public_header_files = 'SHKit/Classes/Map/BaiduMap/*.h'
  #           bsp.ios.vendored_frameworks = 'SHKit/Classes/Map/BaiduMap/SDKs/*.framework'
  #           bsp.vendored_libraries = 'SHKit/Classes/Map/BaiduMap/SDKs/thirdlibs/*.a'
  #           bsp.libraries = 'sqlite3', 'c++'
  #           bsp.frameworks = 'CoreLocation', 'QuartzCore', 'OpenGLES', 'SystemConfiguration', 'CoreGraphics', 'Security', 'CoreTelephony', 'MobileCoreServices'
  #           bsp.resource_bundles = {
  #               'BaiduMap' => ['SHKit/Classes/Map/BaiduMap/Resources/*']
  #           }
  #           bsp.resource = 'SHKit/Classes/Map/BaiduMapSDKs/BaiduMapAPI_Map.framework/mapapi.bundle'
  #           bsp.dependency 'ShFlyKit/Base'
  #           bsp.pod_target_xcconfig = {
  #               'OTHER_LDFLAGS' => '-ObjC',
  #               'ENABLE_BITCODE' => 'NO'
  #           }
  #         end
  #
  #   end
end
