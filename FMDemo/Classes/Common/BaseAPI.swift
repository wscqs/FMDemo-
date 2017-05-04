//
//  BaseAPI.swift
//  ban
//
//  Created by mba on 16/8/22.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import UIKit
let publicEnvironment = "publicEnvironment"

/// 基础url
var kKeBaseURL:String {

    if UserDefaults.standard.bool(forKey: publicEnvironment) {
        return "http://ke.mbalib.com/api/"
    } else {
        return "http://192.168.1.12:8013/api/"
    }
}

/// 用户模块
//return "http://passport.mbalib.com/api2/loginweixin/"
var kUserBaseURL:String{

    if UserDefaults.standard.bool(forKey: publicEnvironment) {
        return "http://passport.mbalib.com/api2/"
    } else {
        return "http://192.168.1.12:8082/api2/"
    }
}



//微信
let kAppKeyWXID = "wx4183ac8e8edbd09d"
let kAppKeyWXAppSecret = "57233f9cf6cddc93da7ea624e1ad744c"


