//
//  AppDelegate.swift
//  FMDemo
//
//  Created by mba on 16/11/30.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import UIKit
import WechatKit
import UserNotifications
//import IQKeyboardManagerSwift
//import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

//        print(AccessTokenModel.shared?.accessToken,AccessTokenModel.shared?.uid,AccessTokenModel.shared?.loginToken)
        

        setupGlobalStyle()        // 配置全局样式
        setupGlobalData()         // 配置全局数据
        setupRootViewController() // 配置控制器
//        setupKeyBoardManager() //配置全局键盘
        
        
        return true
    }
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return WechatManager.sharedInstance.handleOpenURL(url)
        
        // 如需要使用其他第三方可以 使用 || 连接 其他第三方库的handleOpenURL
        // return WechatManager.sharedInstance.handleOpenURL(url) || TencentOAuth.HandleOpenURL(url) || WeiboSDK.handleOpenURL(url, delegate: SinaWeiboManager.sharedInstance) ......
        
//        return true
    }
}

extension AppDelegate {
    
    /**
     根控制器
     */
    // MARK: - rootVC
    fileprivate func setupRootViewController() {
        
        window?.backgroundColor = UIColor.white

//        if AccessTokenModel.shared?.accessToken?.isEmpty ?? true{
//            window?.rootViewController = LoginViewController()
//        } else {
//            let mainVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()
//            window?.rootViewController = mainVC
//        }
        let vc = UIStoryboard(name: "Record", bundle: nil).instantiateInitialViewController()
//        let vc = RecordViewController()
        let navigation = QSNavigationController(rootViewController: vc!)
        window?.rootViewController = navigation
        MBAProgressHUD.show()
        window?.makeKeyAndVisible()
    }
    
    /**
     全局样式
     */
    fileprivate func setupGlobalStyle() {
        
        setupGlobalNav()
        
        MBAProgressHUD.setupHUD() // 配置HUD
        // 3. 设置用户授权显示通知
        // #available 是检测设备版本，如果是 10.0 以上
//        if #available(iOS 10.0, *) {
//            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .carPlay, .sound]) { (success, error) in
//                //                print("授权 " + (success ? "成功" : "失败"))
//            }
//        } else {
//            let notifySettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//            UIApplication.shared.registerUserNotificationSettings(notifySettings)
//        }
    }
    
    fileprivate func setupGlobalData() {
        WechatManager.appid = kAppKeyWXID
        WechatManager.appSecret = kAppKeyWXAppSecret
    }
    
    /// 设置导航条和工具条的外观
    fileprivate func setupGlobalNav() {
        //因为外观一旦设置全局有效, 所以应该在程序一进来就设置
        let appearance = UINavigationBar.appearance()
        appearance.setBackgroundImage(UIImage.imageWithColor(UIColor.colorWithHexString(kGlobalNavBgColor), size: CGSize(width: 0, height: 0)), for: UIBarMetrics.default)
        appearance.shadowImage = UIImage()
        var textAttrs: [String : AnyObject] = Dictionary()
        textAttrs[NSForegroundColorAttributeName] = UIColor.white
        textAttrs[NSFontAttributeName] = UIFont.systemFont(ofSize: 20)
        appearance.titleTextAttributes = textAttrs
        appearance.tintColor = UIColor.white
        
        appearance.isTranslucent = false
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
//    /**
//     配置键盘管理者
//     */
//    fileprivate func setupKeyBoardManager() {
//        IQKeyboardManager.sharedManager().enable = true
//    }
}

