//
//  AccessTokenModel.swift
//
//  Created by mba on 16/8/19
//  Copyright (c) . All rights reserved.
//

import Foundation
import ObjectMapper

open class AccessTokenModel: BaseModel, NSCoding {
    
    
//    MARK:-
    static func storeBean(_ bean: AccessTokenModel) {
        let data = NSKeyedArchiver.archivedData(withRootObject: bean)
        UserDefaults.standard.set(data, forKey: "AccessTokenModel")
    }

    static var shared: AccessTokenModel? {
        let bean = UserDefaults.standard.object(forKey: "AccessTokenModel") as? Data
        if let bean = bean {
            return NSKeyedUnarchiver.unarchiveObject(with: bean) as? AccessTokenModel ?? nil
        }else {
            return nil
        }
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(loginToken, forKey: kAccessTokenModelLoginTokenKey)
        aCoder.encode(accessToken, forKey: kAccessTokenModelAccessTokenKey)
        aCoder.encode(uid, forKey: kAccessTokenModelUidKey)
    }
    

    
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        loginToken = aDecoder.decodeObject(forKey: kAccessTokenModelLoginTokenKey) as? String
        accessToken = aDecoder.decodeObject(forKey: kAccessTokenModelAccessTokenKey) as? String
        uid = aDecoder.decodeObject(forKey: kAccessTokenModelUidKey) as? String
    }

    // MARK: Declaration for string constants to be used to decode and also serialize.
	internal let kAccessTokenModelLoginTokenKey: String = "login_token"
	internal let kAccessTokenModelAccessTokenKey: String = "access_token"
	internal let kAccessTokenModelUidKey: String = "uid"


    // MARK: Properties
	open var loginToken: String?
	open var accessToken: String?
	open var uid: String?



    // MARK: ObjectMapper Initalizers
    /**
    Map a JSON object to this class using ObjectMapper
    - parameter map: A mapping from ObjectMapper
    */

    
    public required init?(map: Map) {
       super.init(map: map)
    }

    /**
    Map a JSON object to this class using ObjectMapper
    - parameter map: A mapping from ObjectMapper
    */
    open override func mapping(map: Map) {
        super.mapping(map: map)
		loginToken <- map[kAccessTokenModelLoginTokenKey]
		accessToken <- map[kAccessTokenModelAccessTokenKey]
		uid <- map[kAccessTokenModelUidKey]

    }

    /**
    Generates description of the object in the form of a NSDictionary.
    - returns: A Key value pair containing all valid values in the object.
    */
    open func dictionaryRepresentation() -> [String : AnyObject ] {

        var dictionary: [String : AnyObject ] = [ : ]
		if loginToken != nil {
			dictionary.updateValue(loginToken! as AnyObject, forKey: kAccessTokenModelLoginTokenKey)
		}
		if accessToken != nil {
			dictionary.updateValue(accessToken! as AnyObject, forKey: kAccessTokenModelAccessTokenKey)
		}
		if uid != nil {
			dictionary.updateValue(uid! as AnyObject, forKey: kAccessTokenModelUidKey)
		}

        return dictionary
    }

}
