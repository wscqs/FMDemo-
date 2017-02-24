//
//  SQRequest.swift
//  ban
//
//  Created by mba on 16/7/28.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import Toaster

let kNetworkDontUse = "网络不可用"
let kServiceDontUse = "服务端出错，请稍后重试"

/// 上传的data 真实格式
enum dataType: String {
    case mp3,img
}

public enum CachePolicy: String {
    case Default,// *** 不提供缓存
    ReturnCache_ElseLoad,// *** 如果有缓存则返回缓存不加载网络，否则加载网络数据并且缓存数据
    ReturnCache_DontLoad,// *** 如果有缓存则返回缓存并且不加载网络（用于离线模式）
    ReturnCache_DidLoad,// *** 如果有缓存则返回缓存并且都加载网络
    ReturnCacheOrNil_DidLoad,// *** 如果 有缓存则返回缓存,没有缓存就返回空的,并且都加载网络
    Reload_IgnoringLocalCache,// *** 忽略本地缓存并加载 （使用在更新缓存）
 
    ReturnCache_WhenLoadFail// *** 加载失败返回缓存
}

let alamofireManager: SessionManager = {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 5    // 秒
    return Alamofire.SessionManager(configuration: configuration)
}()

class MBARequest<T: BaseModel> : NSObject{
    
    
    /// T?:实体 error:错误信息
    typealias finished = (T?, NSError?)-> ()
   

    /// 通用请求方法
    ///
    /// - parameter url:               url
    /// - parameter method:            method 默认.get
    /// - paramet er params:            params
    /// - parameter cache:             缓存策略
    /// - parameter showHUD:           是否显示加载
    /// - parameter completionHandler: 回调
    public static func go(url: String,
                           method: HTTPMethod = .get,
                           params: [String: Any]? = Dictionary(),
                           cache: CachePolicy = .Default,
                           showHUD: Bool = false,
                           completionHandler:@escaping finished)
    {
        
        let fullUrl = getFullUrl(url,params)
        debugPrint(fullUrl)
        
        switch cache {
        case .Default:
            req(url: url, method: method, params: params, cache: cache, showHUD: showHUD, completionHandler: completionHandler)

        case .ReturnCache_ElseLoad:
          
            MBACache.fetchJson(key: fullUrl, compledHandle: { (data) in
                if let data = data{
                    let object = transformBean(with: data)
                    object?.isCache = true
                    completionHandler(object, nil)
                } else {
                    req(url: url, method: method, params: params, cache: cache, showHUD: showHUD, completionHandler: completionHandler)
                }
            })
            
        case .ReturnCache_DontLoad:

            MBACache.fetchJson(key: fullUrl, compledHandle: { (data) in
                if let data = data{
                    let object = transformBean(with: data)
                    object?.isCache = true
                    completionHandler(object, nil)
                } else {
                    req(url: url, method: method, params: params, cache: cache, showHUD: showHUD, completionHandler: completionHandler)
                }
            })
            
        case .ReturnCache_DidLoad:
            
            MBACache.fetchJson(key: fullUrl, compledHandle: { (data) in
                if let data = data{
                    let object = transformBean(with: data)
                    object?.isCache = true
                    completionHandler(object, nil)
                } else {
                    req(url: url, method: method, params: params, cache: cache, showHUD: showHUD, completionHandler: completionHandler)
                }
            })
            
            req(url: url, method: method, params: params, cache: cache, showHUD: showHUD, completionHandler: completionHandler)
            
        case .ReturnCacheOrNil_DidLoad:
            MBACache.fetchJson(key: fullUrl, compledHandle: { (data) in
                if let data = data{
                    let object = transformBean(with: data)
                    object?.isCache = true
                    completionHandler(object, nil)
                } else {
                    completionHandler(nil, nil)
                }
            })
            req(url: url, method: method, params: params, cache: cache, showHUD: showHUD, completionHandler: completionHandler)
        case .Reload_IgnoringLocalCache:
            req(url: url, method: method, params: params, cache: cache, showHUD: showHUD, completionHandler: completionHandler)            
            
        case .ReturnCache_WhenLoadFail:
            req(url: url, method: method, params: params, cache: cache, showHUD: showHUD, completionHandler: completionHandler)
//        default:
//            req(url: url, method: method, params: params, cache: cache, showHUD: showHUD, completionHandler: completionHandler)
        }
    }
    
    /// 通用请求方法
    ///
    /// - parameter url:               url
    /// - parameter method:            method 默认.get
    /// - parameter params:            params
    /// - parameter cache:             缓存策略
    /// - parameter showHUD:           是否显示加载
    /// - parameter completionHandler: 回调
    public static func goSafe(url: String,
                          method: HTTPMethod = .get,
                          params: [String: Any]? = Dictionary(),
                          cache: CachePolicy = .Default,
                          showHUD: Bool = false,
                          completionHandler:@escaping finished)
    {

        MBACache.fetchString(key: kUserAccessToken) { (accessToken) in
            if let accessToken = accessToken {
                if var params = params {
                    params["access_token"] = accessToken
                    go(url: url, method: method, params: params, cache: cache, showHUD: showHUD, completionHandler: completionHandler)
                }
            } else {
                completionHandler(nil, NSError())
                // 获取token 后请求
                postLoginNotification()
            }
        }

    }
    
    
    
    /// 有token的上传
    ///
    /// - Parameters:
    ///   - url: url
    ///   - params: params
    ///   - dataType: data的真实格式，默认MP3
    ///   - showHUD: 是否显示hud
    ///   - completionHandler: 回调
    public static func goSafeUpload(url: String,
                params: [String: Any]? = Dictionary(),
                dataType: dataType = .mp3,
                showHUD: Bool = false,
                completionHandler:@escaping finished)
    {
        MBACache.fetchString(key: kUserAccessToken) { (accessToken) in
            if let accessToken = accessToken {
                if var params = params {
                    params["access_token"] = accessToken

                    alamofireManager.upload(multipartFormData: { (multipartFormData) in
                        
                        for (key, value) in params {
                            if let valueData = (value as? Data) {
                                switch dataType {
                                case .mp3:
                                    multipartFormData.append(valueData, withName: key, fileName: Date().description + ".mp3", mimeType: "audio/mpeg")
                                case .img:
                                    multipartFormData.append(valueData, withName: key, fileName: Date().description + ".png", mimeType: "image/*")
                                }
                                
                            }else {
                                let valueData = (String(describing: value)).data(using: .utf8)
                                multipartFormData.append(valueData!, withName: key)
                            }
                            
                        }
                        }, to: url)
                    { (encodingResult) in
                        switch encodingResult{
                        case .success(let upload, _, _):
                            
                            upload.responseJSON(completionHandler: { (response) in

                                switch response.result {
                                case .success(let json):
                                    guard let json = json as? [String: Any] else{
                                        MBAToast.show(text: kServiceDontUse)
                                        completionHandler(nil, NSError())
                                        return
                                    }
                                    
                                    if let errcode = (json["errorno"] as? Int),
                                        let errmsg = (json["error"] as? String){  // 以前的登录，wiki错误判断
                                        
                                        if errcode == 10001 {// token 出错
                                            
                                            DispatchQueue.main.async {
                                                KeService.actionAccessToken({ (isSuccess) in
                                                    if isSuccess {
                                                        DispatchQueue.main.async {
                                                            goSafeUpload(url: url, params: params, showHUD: showHUD, completionHandler: completionHandler)
                                                        }
                                                    }
                                                }, failure: { (error) in
                                                })
                                            }
                                        }else if errcode == 10002 {// loginToken 过期
                                            let error = NSError(domain: errmsg, code: errcode, userInfo: nil)
                                            completionHandler(nil, error)
                                            return
                                        }else{
                                            MBAToast.show(text: errmsg)
                                            let error = NSError(domain: errmsg, code: errcode, userInfo: nil)
                                            completionHandler(nil, error)
                                            return

                                        }
                                        MBAToast.show(text: errmsg)
                                        let error = NSError(domain: errmsg, code: errcode, userInfo: nil)
                                        completionHandler(nil, error)
                                        return
                                    }else {
                                        let object = transformBean(with: json)
                                        
                                        //                    debugPrint("result --------",json)
                                        //                    debugPrint(object)
                                        completionHandler(object, nil)
                                    }
                                    
                                case .failure(let error):
                                    MBAToast.show(text: kNetworkDontUse)
                                    completionHandler(nil, error as NSError?)
                                }
                                
                                
                                
                            })
                            
                        case .failure(let error):
                            completionHandler(nil, error as NSError?)
                        }
                    }
                    
                    
                }
                
            } else {
                completionHandler(nil, nil)
                // 获取token 后请求
                postLoginNotification()
            }
        }
    }

    
    /// 通用请求方法
    ///
    /// - parameter url:               url
    /// - parameter method:            method 默认.get
    /// - parameter params:            params
    /// - parameter cache:             缓存策略
    /// - parameter showHUD:           是否显示加载
    /// - parameter completionHandler: 回调
    fileprivate static func req(url: String,
            method: HTTPMethod = .get,
            params: [String: Any]? = Dictionary(),
            cache: CachePolicy = .Default,
            showHUD: Bool = false,
            completionHandler:@escaping finished) {
       
        if !NetworkTool.isReachable() {
            MBAToast.show(text: kNetworkDontUse)
            let error = NSError(domain: kNetworkDontUse, code: 555, userInfo: nil)
            
            if cache != .Default{
                let fullUrl = getFullUrl(url,params)
                
                MBACache.fetchJson(key: fullUrl, compledHandle: { (data) in
                    if let data = data{
                        let object = transformBean(with: data)
                        completionHandler(object, nil)
                    } else {
                        let error = NSError(domain: kNetworkDontUse, code: 555, userInfo: nil)
                        completionHandler(nil, error)
                    }
                })

            }else {
                completionHandler(nil, error)
            }
            
            return
        }
        if showHUD {
            MBAProgressHUD.show()
        }
        
        
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    
        alamofireManager.request(url, method: method, parameters: params).responseJSON { (response) in
            
            if showHUD {
                MBAProgressHUD.dismiss()
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            switch response.result {
            case .success(let json):
                
                guard let json = json as? [String: Any] else{
                    MBAToast.show(text: kServiceDontUse)
                    completionHandler(nil, NSError())
                    return
                }
                
                if let errcode = (json["errorno"] as? Int),
                    let errmsg = (json["error"] as? String){  // 以前的登录，wiki错误判断

                    if errcode == 10001 {// token 出错

                        DispatchQueue.main.async {
                            KeService.actionAccessToken({ (isSuccess) in
                                if isSuccess {
                                    DispatchQueue.main.async {
                                        goSafe(url: url, method: method, params: params, cache: cache, showHUD: showHUD, completionHandler: completionHandler)
                                    }
                                }
                            }, failure: { (error) in
                            })
                        }
                    }else if errcode == 10002 {// loginToken 过期
                        let error = NSError(domain: errmsg, code: errcode, userInfo: nil)
                        completionHandler(nil, error)
                        return
                    }else{
                        MBAToast.show(text: errmsg)
                        let error = NSError(domain: errmsg, code: errcode, userInfo: nil)
                        completionHandler(nil, error)
                        return
                    }

                    
                    
                }else {
                    
                    let object = transformBean(with: json)
                    
//                    debugPrint("result --------",json)
//                    debugPrint(object)
                    
                    if cache != .Default{
                        MBACache.setJson(value: json, key: getFullUrl(url,params))
                    }
                    completionHandler(object, nil)
                }
            
            case .failure(let error):
                print(error.localizedDescription)
                MBAToast.show(text: kServiceDontUse)
                completionHandler(nil, error as NSError?)
            }
        }

    }

    
    // 获取全路径
    fileprivate static func getFullUrl(_ url: String,_ params: [String: Any]? = Dictionary()) -> String {
        var fullUrl = ""
        if params?.count ?? 0 > 0{
            var str: String = "?"
            for param in params! {
                if let value = (param.1 as? [Any]){
                    str += "\(param.0)=\(value)&"
                }else {
                    str += "\(param.0)=\(param.1)&"
                }
            }
            str = (str as NSString).substring(to: str.characters.count - 1)
            fullUrl = url + str
        }else {
            fullUrl = url
        }
        //        fullUrl.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        return fullUrl
    }
    
    /// 转化jsontoBean
    ///
    /// - parameter json: json
    ///
    /// - returns: 对象？
    fileprivate static func transformBean(with json: [String: Any]) -> T?{
        var object: T?
        if let data = json["data"] {
            if let _ = (data as? [Any]) { // 数组
                object = Mapper<T>().map(JSON: json)
            }
            
            else if let data = (data as? [String: Any]){ // 对象
                object = Mapper<T>().map(JSON: data)
            }
            
            else  { // 单个
                object = Mapper<T>().map(JSON: json)
            }
        } else {
            object = Mapper<T>().map(JSON: json)
        }
        return object
    }
    
    /// 发送登录请求
    static func postLoginNotification(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUserShouldLoginNotification), object: nil, userInfo: nil)
    }
    
    
}



/// 网络判断
class NetworkTool {

    static let networkManager = NetworkReachabilityManager()

    /**
     网络是否可用
     */
    class func isReachable() -> Bool {
        return networkManager!.isReachable
    }

    /**
     网络是否WWAN(3G,4G)
     */
    class func isReachableOnWWAN() -> Bool {
        return networkManager!.isReachableOnWWAN
    }

    /**
     网络是否WiFi
     */
    class func isReachableOnEthernetOrWiFi() -> Bool {
        return networkManager!.isReachableOnEthernetOrWiFi
    }

}
