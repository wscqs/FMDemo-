//
//  Data.swift
//
//  Created by mba on 17/2/23
//  Copyright (c) . All rights reserved.
//

import Foundation
import ObjectMapper

public class GetMaterialsData: Mappable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kDataTimeKey: String = "time"
  private let kDataMidKey: String = "mid"
  private let kDataTitleKey: String = "title"
  private let kDataStateKey: String = "state"
  private let kDataURLKey: String = "url"

  // MARK: Properties
  public var time: String?
  public var mid: String?
  public var title: String?
  public var state: String?
  public var url: String?

  // MARK: ObjectMapper Initalizers
  /**
   Map a JSON object to this class using ObjectMapper
   - parameter map: A mapping from ObjectMapper
  */
    required public init?(map: Map){
        
    }

  /**
  Map a JSON object to this class using ObjectMapper
   - parameter map: A mapping from ObjectMapper
  */
  public func mapping(map: Map) {
    time <- map[kDataTimeKey]
    mid <- map[kDataMidKey]
    title <- map[kDataTitleKey]
    state <- map[kDataStateKey]
    url <- map[kDataURLKey]
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = time { dictionary[kDataTimeKey] = value }
    if let value = mid { dictionary[kDataMidKey] = value }
    if let value = title { dictionary[kDataTitleKey] = value }
    if let value = state { dictionary[kDataStateKey] = value }
    if let value = url { dictionary[kDataURLKey] = value }
    return dictionary
  }

}
