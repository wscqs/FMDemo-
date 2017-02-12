//
//  IdsModel.swift
//
//  Created by mba on 16/8/22
//  Copyright (c) . All rights reserved.
//

import Foundation
import ObjectMapper
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


open class IdsModel: BaseModel {

    // MARK: Declaration for string constants to be used to decode and also serialize.
	internal let kIdsModelIdsKey: String = "ids"


    // MARK: Properties
	open var ids: [String]?



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
//		ids <- map[kIdsModelIdsKey]
        let transform = TransformOf<String, Any>(fromJSON: { (value: Any?) -> String? in
            return String(describing: value!)
        }, toJSON: { (value: Any?) -> String? in
            if let value = value {
                return String(describing: value)
            }
            return nil
        })
        ids <- (map[kIdsModelIdsKey],transform)
    }

    /**
    Generates description of the object in the form of a NSDictionary.
    - returns: A Key value pair containing all valid values in the object.
    */
    open func dictionaryRepresentation() -> [String : AnyObject ] {

        var dictionary: [String : AnyObject ] = [ : ]
		if ids?.count > 0 {
			dictionary.updateValue(ids! as AnyObject, forKey: kIdsModelIdsKey)
		}

        return dictionary
    }

}
