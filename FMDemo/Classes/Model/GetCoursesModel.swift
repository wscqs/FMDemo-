//
//  GetCoursesModel.swift
//
//  Created by mba on 17/2/23
//  Copyright (c) . All rights reserved.
//

import Foundation
import ObjectMapper

public class GetCoursesModel: BaseModel {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private let kGetCoursesModelStateKey: String = "state"
  private let kGetCoursesModelDataKey: String = "data"

  // MARK: Properties
  public var state: String?
  public var data: [GetCoursesData]?

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
  public override func mapping(map: Map) {
    super.mapping(map: map)
    state <- map[kGetCoursesModelStateKey]
    data <- map[kGetCoursesModelDataKey]
  }

  /**
   Generates description of the object in the form of a NSDictionary.
   - returns: A Key value pair containing all valid values in the object.
  */
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = state { dictionary[kGetCoursesModelStateKey] = value }
    if let value = data { dictionary[kGetCoursesModelDataKey] = value.map { $0.dictionaryRepresentation() } }
    return dictionary
  }

}
