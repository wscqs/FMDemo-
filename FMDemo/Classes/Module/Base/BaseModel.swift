//
//  BaseModel.swift
//  ban
//
//  Created by mba on 16/7/28.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import UIKit
import ObjectMapper

open class BaseModel: NSObject, Mappable{
    var errorno: Int?    
    var error: String?
    
    var isCache: Bool = false
//    var hasMoreData: Bool = true
    
    override init() {
        
    }
    
//    @discardableResult
//    convenience init(hasMoreData: Bool = true) {
//        self.init()
//        self.hasMoreData = hasMoreData
//    }
    
    public  required init?(map: Map) {
        
    }
    
    open func mapping(map: Map) {
        errorno     <- map["errorno"]
        error     <- map["error"]
    }
}
