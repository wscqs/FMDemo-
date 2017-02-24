//
//  Data.swift
//
//  Created by mba on 17/2/23
//  Copyright (c) . All rights reserved.
//

import Foundation
import ObjectMapper

public class GetCoursesData: Mappable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kDataStateKey: String = "state"
  private let kDataCidKey: String = "cid"
  private let kDataTitleKey: String = "title"
  private let kDataCreatetimeKey: String = "createtime"

  // MARK: Properties
  public var state: String?
  public var cid: String?
  public var title: String?
  public var createtime: String?

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
    state <- map[kDataStateKey]
    cid <- map[kDataCidKey]
    title <- map[kDataTitleKey]
    createtime <- map[kDataCreatetimeKey]
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = state { dictionary[kDataStateKey] = value }
    if let value = cid { dictionary[kDataCidKey] = value }
    if let value = title { dictionary[kDataTitleKey] = value }
    if let value = createtime { dictionary[kDataCreatetimeKey] = value }
    return dictionary
  }

}
