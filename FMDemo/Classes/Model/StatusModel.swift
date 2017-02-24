//
//  StatusModel.swift
//
//  Created by mba on 16/8/26
//  Copyright (c) . All rights reserved.
//

import Foundation
import ObjectMapper

open class StatusModel: BaseModel {

    // MARK: Declaration for string constants to be used to decode and also serialize.
	internal let kStatusModelStateKey: String = "state"


    // MARK: Properties
	open var state: String?



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
		state <- map[kStatusModelStateKey]

    }

    /**
    Generates description of the object in the form of a NSDictionary.
    - returns: A Key value pair containing all valid values in the object.
    */
    open func dictionaryRepresentation() -> [String : AnyObject ] {

        var dictionary: [String : AnyObject ] = [ : ]
		if state != nil {
			dictionary.updateValue(state! as AnyObject, forKey: kStatusModelStateKey)
		}

        return dictionary
    }

}
