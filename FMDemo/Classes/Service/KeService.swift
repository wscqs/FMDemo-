//
//  UserService.swift
//  ban
//
//  Created by mba on 16/8/22.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import UIKit

//let kLoginToken = "loginToken"

class KeService: NSObject {
    
//    http://192.168.1.12:8082/api2/loginweixin?openid=offEEv8lEjTGBYhZ9Y84IxHd1oQ8&unionid=on1rljhfO2IofrN9rBBRAQVzyR4o&weixin_token=q67ch6BoemjCv3UoY9wlGBThJ-c8EmcxxTvqRFvmkSwG7SdASUKaqnHtV6AAj_oTqfe1IMFIsDWNrokiyV4_B1ffY51LWsLJ7zn1XmQJfPo&channel=ketang
    class func actionLoginToken(openid: String,
                                unionid: String,
                                refresh_token: String,
                                 _ success:@escaping (_ isSuccess: Bool)->(),
                                 failure:@escaping (_ error: NSError)->()){
        let url = kUserBaseURL + "accessToken"
        let params = [
            "openid": openid,
            "unionid": unionid,
            "weixin_token": refresh_token,
            "channel": "ketang"
            ]
        MBARequest<LoginModel>.go(url: url, method: .post, params: params, cache: .Default, completionHandler:{ (bean, error) in
            if let loginToken = bean?.login_token {
                MBACache.setString(value: loginToken, key: kBangLoginToken)
//                if let bean = bean {
//                    
//                    success(bean)
//                }
                if let error = error {
                    failure(error)
                }
                
                DispatchQueue.main.async {
                    actionAccessToken({ (bean) in
                        success(true)
                    }, failure: { (error) in
                        
                    })
                }
            }
        })
        
    }

    
    
    /**
     *  action:accesstoken(获取access_token)
     *  parameter:
     * 		login_token
     *  return:
     * 		access_token:
     * 		login_token:
     * 		uid:用户ID
     *  error:
     *  	10002:login_token无效
     *  explain:
     *  	login_token去passport获取
     *  线上:http://passport.mbalib.com/api2/loginweixin
     *  线下:http://192.168.1.12:8082/api2/loginweixin
     *
     */
    class func actionAccessToken(
                            _ success:@escaping (_ isSuccess: Bool)->(),
                            failure:@escaping (_ error: NSError)->()){
        
        let url = kKeBaseURL + "accessToken"
        
        MBACache.fetchString(key: kBangLoginToken) { (loginToken) in
            if let loginToken = loginToken {
                let params = [
                    "login_token": loginToken,
                    ]
                MBARequest<AccessTokenModel>.go(url: url, method: .post, params: params as [String : AnyObject]?, cache: .Default, completionHandler: { (bean, error) in
                    if let bean = bean {
                        AccessTokenModel.storeBean(bean)
                        success(true)
                    }
                    if let error = error {
                        if 10002 == error.code { // logintoken 过期
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUserShouldLoginNotification), object: nil, userInfo: nil)
                        }
                        failure(error)
                    }
                })
                
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUserShouldLoginNotification), object: nil, userInfo: nil)
            }
        }

//        let url = kUserBaseURL + "accessToken"
//        let params = [
//            "login_token": login_token,
//            ]
//        MBARequest<AccessTokenModel>.go(url: url, method: .post, params: params, cache: .Default, completionHandler: { (bean, error) in
//            DispatchQueue.main.async {
//                if let token = bean?.accessToken {
//                    MBACache.setString(value: token, key: kBangAccessToken)
//                }
//            }
//            if let bean = bean {
//                success(bean)
//            }
//            if let error = error {
//                if 10002 == error.code { // logintoken 过期
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUserShouldLoginNotification), object: nil, userInfo: nil)
//                }
//                failure(error)
//            }
//        })

//        MBACache.fetchString(key: kBangLoginToken) { (loginToken) in
//            if let loginToken = loginToken {
//                let params = [
//                    "login_token": loginToken,
//                    ]
//                
//            } else {
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUserShouldLoginNotification), object: nil, userInfo: nil)
//            }
//        }
    }

}
