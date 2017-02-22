//
//  BangUserAccount.swift
//  bang
//
//  Created by mba on 16/11/2.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import Foundation
import ObjectMapper

fileprivate let userAccountKey = "userAccount"

class KeUserAccount {
    
    
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
        MBACache.removeString(key: kBangAccessToken)
        MBACache.removeString(key: kBangLoginToken)
    }
    
    
    static var shared: AccessTokenModel? {
        if let usersString = UserDefaults.standard.string(forKey: userAccountKey){
            return Mapper<AccessTokenModel>().map(JSONString: usersString)
        }else {
            return nil
        }
        
    }
}
