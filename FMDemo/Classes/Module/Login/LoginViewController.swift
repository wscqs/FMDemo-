//
//  LoginViewController.swift
//  FMDemo
//
//  Created by mba on 17/2/8.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 微信登录拿到refresh_token 到服务端拿token
        NotificationCenter.default.addObserver(self, selector:#selector(recviceWX_CODE_Notification(n:)), name: NSNotification.Name(rawValue: "WX_CODE"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func actionWechatLogin(_ sender: UIButton) {
        sendWXAuthRequest()
    }
    
    fileprivate func sendWXAuthRequest() {
        let req : SendAuthReq = SendAuthReq()
        req.scope = "snsapi_userinfo,snsapi_base"
        req.state = "XXX"
        req.openID = kAppKeyWXID
        WXApi.sendAuthReq(req, viewController: self, delegate: WXApiManager.share)
    }
    
    func recviceWX_CODE_Notification(n: Notification) {
        guard let code = (n.userInfo?["code"] as? String) else {
            MBAProgressHUD.showErrorWithStatus("授权出错，重新登录")
            return
        }
        getAccess_token(code: code)
    }
    
    // 微信登录后 获取课堂的accesstoken
    func getAccess_token(code :String){
        
        let requestUrl = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=\(kAppKeyWXID)&secret=\(kAppKeyWXAppSecret)&code=\(code)&grant_type=authorization_code"
        
        DispatchQueue.global().async {
            let requestURL = URL(string: requestUrl)!
            let data = try? Data(contentsOf: requestURL, options: NSData.ReadingOptions())
            DispatchQueue.main.async {
                let jsonResult: NSDictionary = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
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

}


// MARK:- 微信登录后回调
class WXApiManager: NSObject, WXApiDelegate {
    static let share = WXApiManager()
    func onResp(_ resp: BaseResp!) {
        let aresp = resp as! SendAuthResp
        if (aresp.errCode == 0)
        {
            let dic:Dictionary<String,String>=["code":aresp.code];
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WX_CODE"), object: nil, userInfo: dic)
        }
    }
    
}
