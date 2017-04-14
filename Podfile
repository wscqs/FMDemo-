# Uncomment the next line to define a global platform for your project
 platform :ios, '9.0'

target 'FMDemo' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

#----------------OC----------------
pod 'MJRefresh' #https://github.com/CoderMJLee/MJRefresh
pod 'DZNEmptyDataSet' #https://github.com/dzenbot/DZNEmptyDataSet
pod 'SVProgressHUD' #https://github.com/SVProgressHUD/SVProgressHUD
pod 'ZLPhotoBrowser' #https://github.com/longitachi/ZLPhotoBrowser

  pod 'Kingfisher'
#  pod 'AlamofireObjectMapper'
#pod 'SnapKit'
  #pod 'WechatKit'
  #-Networking
  pod 'Alamofire', '~> 4.0' #https://github.com/Alamofire/Alamofire
  #pod 'SwiftyJSON'
  pod 'ObjectMapper' #https://github.com/Hearst-DD/ObjectMapper
  pod 'HanekeSwift', :git => 'https://github.com/Haneke/HanekeSwift', :branch => 'feature/swift-3'
  #-UI
  pod 'Toaster', '~> 2.0' #https://github.com/devxoul/Toaster
  #Tool
#  pod 'IQKeyboardManagerSwift' #https://github.com/hackiftekhar/IQKeyboardManager

end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
