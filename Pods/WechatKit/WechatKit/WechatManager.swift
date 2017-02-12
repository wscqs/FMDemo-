//
//  WechatManager.swift
//  WechatKit
//
//  Created by starboychina on 2015/12/02.
//  Copyright © 2015年 starboychina. All rights reserved.
//

import Foundation

/// WechatManager
open class WechatManager: NSObject {
    /// It use to store openid, access_token, refresh_token
    fileprivate static let Defaults = UserDefaults.standard

    /// A closure used to receive and process request from Third-party
    public typealias AuthHandle = (Result<[String: Any], Int32>) -> ()

    /// A closure used to receive and process request from Wechat
    var completionHandler: AuthHandle!

    /// 微信开放平台,注册的应用程序id
    open static var appid: String! {
        didSet {
            WXApi.registerApp(appid)
        }
    }
    /// 微信开放平台,注册的应用程序Secret
    open static var appSecret: String!
    /// openid
    open static var openid: String! {
        didSet {
            Defaults.set(self.openid, forKey: "wechatkit_openid")
            Defaults.synchronize()
        }
    }
    /// access token
    open static var accessToken: String! {
        didSet {
            Defaults.set(self.accessToken, forKey: "wechatkit_access_token")
            Defaults.synchronize()
        }
    }
    /// refresh token
    open static var refreshToken: String! {
        didSet {
            Defaults.set(self.refreshToken, forKey: "wechatkit_refresh_token")
            Defaults.synchronize()
        }
    }
    /// unionid
    open static var unionid: String! {
        didSet {
            Defaults.set(self.unionid, forKey: "wechatkit_unionid")
            Defaults.synchronize()
        }
    }
    /// csrf
    open static var csrfState = "73746172626f796368696e61"
    /// 分享Delegation
    open var shareDelegate: WechatManagerShareDelegate?
    /// A shared instance
    open static let sharedInstance: WechatManager = {
        let instalce = WechatManager()
        openid = Defaults.string(forKey: "wechatkit_openid")
        accessToken = Defaults.string(forKey: "wechatkit_access_token")
        refreshToken = Defaults.string(forKey: "wechatkit_refresh_token")
        unionid = Defaults.string(forKey: "wechatkit_unionid")
        return WechatManager()
    }()

    /**
     检查微信是否已被用户安装

     - returns: 微信已安装返回true，未安装返回false
     */
    open func isInstalled() -> Bool {
        return WXApi.isWXAppInstalled()
    }

    /**
     处理微信通过URL启动App时传递的数据

     需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用。

     - parameter url: 微信启动第三方应用时传递过来的URL

     - returns: 成功返回true，失败返回false
     */
    open func handleOpenURL(_ url: URL) -> Bool {
        return WXApi.handleOpen(url, delegate: WechatManager.sharedInstance)
    }

}



// MARK: WeiChatDelegate

extension WechatManager: WXApiDelegate {
    /**
    收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
    * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
    * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。

    - parameter req: 具体请求内容，是自动释放的
    */
    public func onReq(_ req: BaseReq) {
        if let temp = req as? ShowMessageFromWXReq {
            self.shareDelegate?.showMessage(temp.message.messageExt)
        }
    }
    /**
    发送一个sendReq后，收到微信的回应

    * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
    * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等

    - parameter resp: 具体的回应内容，是自动释放的
    */
    public func onResp(_ resp: BaseResp) {
        if let temp = resp as? SendAuthResp {
            if 0 == temp.errCode && WechatManager.csrfState == temp.state {
                self.getAccessToken(temp.code)
            } else {
                completionHandler(.failure(WXErrCodeCommon.rawValue))
            }
        }
    }

}
