//
//  LoginViewController.swift
//  FMDemo
//
//  Created by mba on 17/2/8.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit
//import WechatKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector:#selector(onRecviceWX_CODE_Notification(n:)), name: NSNotification.Name(rawValue: "WX_CODE"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func onRecviceWX_CODE_Notification(n: Notification) {
        guard let code = (n.userInfo?["code"] as? String) else {
            MBAProgressHUD.showErrorWithStatus("授权出错，重新登录")
            return
        }
        getAccess_token(code: code)
    }

    @IBAction func actionWechatLogin(_ sender: UIButton) {
        sendWXAuthRequest()
        //测:
//        KeService.actionLoginToken(openid: "", unionid: "", refresh_token: "", { (isSuccess) in
//            if isSuccess {
//                self.dismiss(animated: true, completion: {
//                    
//                })
//            }
//        }, failure: { (error) in
//            
//        })
    }
    
    func sendWXAuthRequest() {
        let req : SendAuthReq = SendAuthReq()
        req.scope = "snsapi_userinfo,snsapi_base"
        req.state = "XXX"
        req.openID = kAppKeyWXID
        WXApi.sendAuthReq(req, viewController: self, delegate: WXApiManager.share)
    }
    
    //获取token 第三步
    func getAccess_token(code :String){
        
        let requestUrl = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=\(kAppKeyWXID)&secret=\(kAppKeyWXAppSecret)&code=\(code)&grant_type=authorization_code"
        
        DispatchQueue.global().async {
            let requestURL = URL(string: requestUrl)!
            let data = try? Data(contentsOf: requestURL, options: NSData.ReadingOptions())
            DispatchQueue.main.async {
                let jsonResult: NSDictionary = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
//                print(jsonResult.debugDescription)
                let refresh_token: String = jsonResult["refresh_token"] as! String
                let openid: String = jsonResult["openid"] as! String
                let unionid: String = jsonResult["unionid"] as! String
                KeService.actionLoginToken(openid: openid, unionid: unionid, refresh_token: refresh_token, { (isSuccess) in
                    if isSuccess {
                        self.dismiss(animated: true, completion: {
                            
                        })
                    }
                }, failure: { (error) in
                    
                })
            }
        }
    }

//    func clcik() {
//        if !WechatManager.sharedInstance.isInstalled() {
//            MBAProgressHUD.showErrorWithStatus("请安装微信")
//            return
//        }
//        
//        var wechatUser = WechatUser()
//        WechatManager.sharedInstance.checkAuth { result in
//            switch result {
//            case .failure(let errCode)://登录失败
//                print(errCode)
//            case .success(let value)://登录成功 value为([String: String]) 微信返回的openid access_token 以及 refresh_token
//                print(value)
//                guard let refresh_token = value["refresh_token"] as? String,
//                    let openid = value["openid"] as? String
//                    else {
//                        return
//                }
//                wechatUser.openid = openid
//                wechatUser.refresh_token = refresh_token
//                
//                WechatManager.sharedInstance.getUserInfo { result in
//                    switch result {
//                    case .failure(let errCode)://获取失败
//                        print(errCode)
//                    case .success(let value)://获取成功 value为([String: String]) 微信用户基本信息
//                        print(value)
//                        
//                        guard let headimgurl = value["headimgurl"] as? String,
//                            let unionid = value["unionid"] as? String,
//                            let nickname = value["nickname"] as? String
//                            else {
//                                return
//                        }
//                        wechatUser.unionid = unionid
//                        wechatUser.headimgurl = headimgurl
//                        wechatUser.nickname = nickname
//                        //                        MBACache.setString(value: headimgurl, key: kUserAvator)
//                        //                        MBACache.setString(value: nickname, key: kUserName)
//                        
//                        self.login(wechatUser: wechatUser)
//                    }
//                }
//            }
//        }
//    }
    
//    func login(wechatUser: WechatUser) {
//
//        DispatchQueue.main.async {
//            KeService.actionLoginToken(openid: wechatUser.openid ?? "", unionid: wechatUser.unionid ?? "", refresh_token: wechatUser.refresh_token ?? "", { (isSuccess) in
//                if isSuccess {
//                    self.dismiss(animated: true, completion: {
//                        
//                    })
//                }
//            }, failure: { (error) in
//                
//            })
//            
//        }
//    }
}


class WXApiManager:NSObject, WXApiDelegate {
    static let share = WXApiManager()
    func onResp(_ resp: BaseResp!) {
        let aresp = resp as! SendAuthResp
        print(aresp.errCode)
        
        if (aresp.errCode == 0)
        {
            let dic:Dictionary<String,String>=["code":aresp.code];
//            let value =  dic["code"]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WX_CODE"), object: nil, userInfo: dic)
        }
    }
    
}

struct WechatUser {
    var openid: String?
    var unionid: String?
    var refresh_token: String?
    var nickname: String?
    var headimgurl: String?
    
    //MARK:-
//    static func storeBean(_ bean: WechatUser) {
//        UserDefaults.standard.set(bean, forKey: "WechatUser")
//        UserDefaults.standard.synchronize()
//    }
//    
//    static var shared: WechatUser? {
//        let bean = UserDefaults.standard.object(forKey: "WechatUser") as? WechatUser
//        if let bean = bean {
//            return bean
//        }else {
//            return nil
//        }
//    }
}
