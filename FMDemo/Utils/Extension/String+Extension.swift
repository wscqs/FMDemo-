//
//  String+Extension.swift
//  QSBaoKan
//
//  Created by mba on 16/6/7.
//  Copyright © 2016年 cqs. All rights reserved.
//

import UIKit

extension String{
    
    // MARK: 缓存目录
    /**
    将当前字符串拼接到cache目录后面
    */
    func cacheDir() -> String{
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!  as NSString
        return path.appendingPathComponent((self as NSString).lastPathComponent)
    }
    /**
    将当前字符串拼接到doc目录后面
    */
    func docDir() -> String
    {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!  as NSString
        return path.appendingPathComponent((self as NSString).lastPathComponent)
    }
    
    
    /**
     将当前字符串拼接到doc目录后面
     */
    func docRecordDir() -> String
    {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!  as NSString
        let recordPath = path.appendingPathComponent("record")
        if !FileManager.default.fileExists(atPath: recordPath) {
            do{
                try FileManager.default.createDirectory(atPath: recordPath, withIntermediateDirectories: false, attributes: nil)
            }catch {
            }
            
        }
        return (recordPath as NSString).appendingPathComponent((self as NSString).lastPathComponent)
    }
    
    func docCutDir() -> String {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!  as NSString
        let recordPath = path.appendingPathComponent("cut")
        if !FileManager.default.fileExists(atPath: recordPath) {
            do{
                try FileManager.default.createDirectory(atPath: recordPath, withIntermediateDirectories: false, attributes: nil)
            }catch {
            }
            
        }
        return (recordPath as NSString).appendingPathComponent((self as NSString).lastPathComponent)
    }
    
    func docMergeDir() -> String {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!  as NSString
        let recordPath = path.appendingPathComponent("merge")
        if !FileManager.default.fileExists(atPath: recordPath) {
            do{
                try FileManager.default.createDirectory(atPath: recordPath, withIntermediateDirectories: false, attributes: nil)
            }catch {
            }
            
        }
        return (recordPath as NSString).appendingPathComponent((self as NSString).lastPathComponent)
    }
    
    func docRecordMP3Dir() -> String {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!  as NSString
        let recordPath = path.appendingPathComponent("recordMP3")
        if !FileManager.default.fileExists(atPath: recordPath) {
            do{
                try FileManager.default.createDirectory(atPath: recordPath, withIntermediateDirectories: false, attributes: nil)
            }catch {
            }
            
        }
        return (recordPath as NSString).appendingPathComponent((self as NSString).lastPathComponent)
    }
    
    
    /**
    将当前字符串拼接到tmp目录后面
    */
    func tmpDir() -> String
    {
        let path = NSTemporaryDirectory() as NSString
        return path.appendingPathComponent((self as NSString).lastPathComponent)
    }
    
    
    // MARK: 时间处理
    /**
     时间戳转为时间
     
     - returns: 时间字符串
     */
    func timeStampToString() -> String
    {
        let string = NSString(string: self)
        let timeSta: TimeInterval = string.doubleValue
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = "yyyy年MM月dd日"
        let date = Date(timeIntervalSince1970: timeSta)
        return dfmatter.string(from: date)
    }
    
    /**
     时间转为时间戳
     
     - returns: 时间戳字符串
     */
    func stringToTimeStamp()->String
    {
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = "yyyy年MM月dd日"
        let date = dfmatter.date(from: self)
        let dateStamp: TimeInterval = date!.timeIntervalSince1970
        let dateSt:Int = Int(dateStamp)
        return String(dateSt)
    }
    
    // MARK: 判断
    /**
     判断手机号是否合法
     - returns: bool
     */
    func isValidMobile() -> Bool {
        // 判断是否是手机号
        let patternString = "^1[3|4|5|7|8][0-9]\\d{8}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", patternString)
        return predicate.evaluate(with: self)
    }
    
    /**
     判断密码是否合法
     - returns: bool
     */
    func isValidPasswod() -> Bool {
        // 验证密码是 6 - 16 位字母或数字
        let patternString = "^[0-9A-Za-z]{6,16}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", patternString)
        return predicate.evaluate(with: self)
    }
    
//    func md5() ->String{
//        let str = self.cString(using: String.Encoding.utf8)
//        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
//        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
//        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
//        CC_MD5(str!, strLen, result)
//        let hash = NSMutableString()
//        for i in 0 ..< digestLen {
//            hash.appendFormat("%02x", result[i])
//        }
//        result.deinitialize()
//        return String(format: hash as String)
//    }
    
}
