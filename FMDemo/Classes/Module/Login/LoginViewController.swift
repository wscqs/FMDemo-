//
//  LoginViewController.swift
//  FMDemo
//
//  Created by mba on 17/2/8.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit
import WechatKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func actionWechatLogin(_ sender: Any) {
        if !WechatManager.sharedInstance.isInstalled() {
            MBAProgressHUD.showWithStatus("请安装微信")
            return
        }
        
        var wechatUser = WechatUser()
        WechatManager.sharedInstance.checkAuth { result in
            switch result {
            case .failure(let errCode)://登录失败
                print(errCode)
            case .success(let value)://登录成功 value为([String: String]) 微信返回的openid access_token 以及 refresh_token
                print(value)
                guard let refresh_token = value["refresh_token"] as? String,
                let openid = value["openid"] as? String
                    else {
                    return
                }
                wechatUser.openid = openid
                wechatUser.refresh_token = refresh_token
 
                WechatManager.sharedInstance.getUserInfo { result in
                    switch result {
                    case .failure(let errCode)://获取失败
                        print(errCode)
                    case .success(let value)://获取成功 value为([String: String]) 微信用户基本信息
                        print(value)
                        
                        guard let headimgurl = value["headimgurl"] as? String,
                            let unionid = value["unionid"] as? String,
                            let nickname = value["nickname"] as? String
                            else {
                                return
                        }
                        wechatUser.unionid = unionid
                        wechatUser.headimgurl = headimgurl
                        wechatUser.nickname = nickname
                        
                        self.login(wechatUser: wechatUser)
                    }
                }
            }
        }
        

        

    }
    
    func login(wechatUser: WechatUser) {
        
        DispatchQueue.main.async {
//            WechatUser.storeBean(wechatUser)
//            let wechatUser = WechatUser.shared
//            guard let openid = wechatUser?.openid,
//                let unionid = wechatUser?.unionid,
//                let refresh_token = wechatUser?.refresh_token
//                else {
//                    return
//            }
            KeService.actionLoginToken(openid: wechatUser.openid ?? "", unionid: wechatUser.unionid ?? "", refresh_token: wechatUser.refresh_token ?? "", { (isSuccess) in
                if isSuccess {
                    print("成功")
                }
            }, failure: { (error) in
                
            })
            
        }
    }
    
    @IBAction func actionExit(_ sender: Any) {
        WechatManager.sharedInstance.logout()
    }
}

struct WechatUser {
    var openid: String?
    var unionid: String?
    var refresh_token: String?
    var nickname: String?
    var headimgurl: String?
    
    //MARK:-
    static func storeBean(_ bean: WechatUser) {
        UserDefaults.standard.set(bean, forKey: "WechatUser")
        UserDefaults.standard.synchronize()
    }
    
    static var shared: WechatUser? {
        let bean = UserDefaults.standard.object(forKey: "WechatUser") as? WechatUser
        if let bean = bean {
            return bean
        }else {
            return nil
        }
    }
}
