//
//  AppDelegate.swift
//  FMDemo
//
//  Created by mba on 16/11/30.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import UIKit

// FIXME: 如果配乐打开， 要把文件夹里面Asset 拉进来

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        setupGlobalStyle()        // 配置全局样式
        setupGlobalData()         // 配置全局数据
        setupRootViewController() // 配置控制器
        
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: NSNotification.Name.LifeCycle.WillResignActive, object: nil)
    }
    
    //微信的跳转回调
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool    {
        return  WXApi.handleOpen(url, delegate: WXApiManager.share)
    }
}

extension AppDelegate {
    
    /**
     根控制器
     */
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
        
        window?.makeKeyAndVisible()
    }
    
    /**
     全局样式
     */
    fileprivate func setupGlobalStyle() {
        setupGlobalNav()
        MBAProgressHUD.setupHUD() // 配置HUD
    }
    
    fileprivate func setupGlobalData() {
        WXApi.registerApp(kAppKeyWXID)
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
}

