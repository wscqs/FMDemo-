//
//  LoginModel.swift
//  ban
//
//  Created by mba on 16/8/19.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import UIKit
import ObjectMapper

class LoginModel: BaseModel {
    var login_token: String?
    

    public required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        login_token    <- map["login_token"]
    }
}
