public protocol CGYJSON {
    func toJSONModel() -> Any?
    func toJSONString() -> String?
}

extension CGYJSON {
    public func toJSONModel() -> Any? {
        let mirror = Mirror(reflecting: self)
        guard mirror.children.count > 0 else {
            return self
        }
        var result: [String: Any] = [:]
        var superClss = mirror.superclassMirror
        while superClss != nil {
            for case let (label?, value) in superClss!.children {
                if let jsonValue = value as? CGYJSON {
                    result[label] = jsonValue.toJSONModel()
                }
            }
            superClss = superClss?.superclassMirror
        }
        for case let (label?, value) in mirror.children {
            if let jsonValue = value as? CGYJSON {
                result[label] = jsonValue.toJSONModel()
            }
        }
        return result
    }
    
    public func toJSONString() -> String? {
        guard let jsonModel = self.toJSONModel() else {
            return nil
        }
        let data = try? JSONSerialization.data(withJSONObject: jsonModel, options: [])
        let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        return str as? String
    }
}

extension Optional: CGYJSON {
    public func toJSONModel() -> Any? {
        if let _self = self {
            if let value = _self as? CGYJSON {
                return value.toJSONModel()
            }
        }
        return NSNull()
    }
}

extension Array: CGYJSON {
    public func toJSONModel() -> Any? {
        var results: [Any] = []
        for item in self {
            if let ele = item as? CGYJSON {
                if let eleModel = ele.toJSONModel() {
                    results.append(eleModel)
                }
            }
        }
        return results
    }
}

extension Dictionary: CGYJSON {
    public func toJSONModel() -> Any? {
        var results: [String: Any] = [:]
        for (key, value) in self {
            if let key = key as? String {
                if let value = value as? CGYJSON {
                    if let valueModel = value.toJSONModel() {
                        results[key] = valueModel
                        continue
                    }
                }
                results[key] = NSNull()
            }
        }
        return results
    }
}

extension NSDate: CGYJSON {
    public func toJSONModel() -> Any? {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormat.string(from: self as Date)
    }
}

extension String: CGYJSON {}
extension Int: CGYJSON {}
extension Int8: CGYJSON {}
extension Int16: CGYJSON {}
extension Int32: CGYJSON {}
extension Int64: CGYJSON {}
extension UInt: CGYJSON {}
extension UInt8: CGYJSON {}
extension UInt16: CGYJSON {}
extension UInt32: CGYJSON {}
extension UInt64: CGYJSON {}
extension Bool: CGYJSON {}
extension Float: CGYJSON {}
extension Double: CGYJSON {}
