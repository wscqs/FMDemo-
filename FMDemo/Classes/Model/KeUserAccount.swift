//
//  BangUserAccount.swift
//  bang
//
//  Created by mba on 16/11/2.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import Foundation
import ObjectMapper
//import WechatKit

fileprivate let userAccountKey = "userAccount"

class KeUserAccount {
    
    /// 判断是否登录
    class var hasAccessToken: Bool {
        return !(KeUserAccount.shared?.accessToken?.isEmpty ?? true)
    }
    
    /**
     1. 偏好设置(小) - Xcode 8 beta 无效！
     2. 沙盒- 归档／plist/`json`
     3. 数据库(FMDB/CoreData)
     4. 钥匙串访问(小／自动加密 - 需要使用框架 SSKeychain)
     */
    class func saveAccount(userAccount: AccessTokenModel) {
        
        // 1. 模型转字典
        let dict = userAccount.toJSONString()
        
        UserDefaults.standard.set(dict, forKey: userAccountKey)
    }
    
    class func cleanAccount() {
        
        UserDefaults.standard.removeObject(forKey: userAccountKey)
        MBACache.removeString(key: kUserLoginToken)
        MBACache.removeString(key: kUserAccessToken)
//        MBACache.removeString(key: kUserName)
//        MBACache.removeString(key: kUserAvator)
//        WechatManager.sharedInstance.logout()
    }
    
    
    static var shared: AccessTokenModel? {
        if let usersString = UserDefaults.standard.string(forKey: userAccountKey){
            return Mapper<AccessTokenModel>().map(JSONString: usersString)
        }else {
            return nil
        }
        
    }
}
