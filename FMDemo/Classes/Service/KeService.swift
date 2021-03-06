//
//  UserService.swift
//  ban
//
//  Created by mba on 16/8/22.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import UIKit


class KeService: NSObject {
    
//    http://192.168.1.12:8082/api2/loginweixin?openid=offEEv8lEjTGBYhZ9Y84IxHd1oQ8&unionid=on1rljhfO2IofrN9rBBRAQVzyR4o&weixin_token=q67ch6BoemjCv3UoY9wlGBThJ-c8EmcxxTvqRFvmkSwG7SdASUKaqnHtV6AAj_oTqfe1IMFIsDWNrokiyV4_B1ffY51LWsLJ7zn1XmQJfPo&channel=ketang
    class func actionWeiXinLoginToken(openid: String,
                                unionid: String,
                                refresh_token: String,
                                 _ success:@escaping (_ isSuccess: Bool)->(),
                                 failure:@escaping (_ error: NSError)->()){
        let url = kUserBaseURL + "loginweixin"
        let params = [
            "openid": openid,
            "unionid": unionid,
            "weixin_token": refresh_token,
            "channel": "ketang"
            ]
//        let params = [
//            "openid": "offEEv8lEjTGBYhZ9Y84IxHd1oQ8",
//            "unionid": "on1rljhfO2IofrN9rBBRAQVzyR4o",
//            "weixin_token": "r47rF-YK8g0LWob_FE_SgCx0VUXoiIbh383rl8QEl4Ua-x8Q0uPwj-znQq9FDU_2afQXhMaC5iFRczUVID1R5IJYZUfl0DEYLbS2yGCXL0s",
//            "channel": "ketang"
//        ]
        MBARequest<LoginModel>.go(url: url, method: .post, params: params, cache: .Default, completionHandler:{ (bean, error) in
            if let loginToken = bean?.login_token {
                MBACache.setString(value: loginToken, key: kUserLoginToken)
                DispatchQueue.main.async {
                    actionAccessToken({ (bean) in
                        success(true)
                    }, failure: { (error) in
                        failure(error)
                    })
                }
            }
            if let error = error {
                failure(error)
            }
        })
        
    }

    
    class func actionMBALoginToken(username:String,
                                   password:String,
                                      _ success:@escaping (_ isSuccess: Bool)->(),
                                      failure:@escaping (_ error: NSError)->()){
        
        
        actionCheckUser(username: username, { (bean) in
            
            
            
            let url = kUserBaseURL + "login"
            let params = [
                "username": username,
                "password": password.md5(),
                ]
            MBARequest<LoginModel>.go(url: url, method: .post, params: params, cache: .Default, completionHandler:{ (bean, error) in
                if let loginToken = bean?.login_token {
                    MBACache.setString(value: loginToken, key: kUserLoginToken)
                    DispatchQueue.main.async {
                        actionAccessToken({ (bean) in
                            success(true)
                        }, failure: { (error) in
                            failure(error)
                        })
                    }
                }
                if let error = error {
                    failure(error)
                }
            })

            
            
        }) { (error) in
            failure(error)
        }
        
        
    }


    
    
    
    /**
     * action:checkUser(校验当前用户名是否可以登录)
     *
     * parameter:
     * 		username
     *
     * return:
     * 		status
     *
     */
    class func actionCheckUser(username: String,                                
                                _ success:@escaping (_ isSuccess: StatusModel)->(),
                                failure:@escaping (_ error: NSError)->()){
        let url = kKeBaseURL + "checkUser"
        let params = [
            "username": username,
        ]
        MBARequest<StatusModel>.go(url: url, method: .post, params: params, cache: .Default, completionHandler:{ (bean, error) in
            if let bean = bean {
                success(bean)
            }
            if let error = error {
                failure(error)
            }
        })
    }


    
    /**
     *  action:accesstoken(获取access_token)
     *  parameter:
     * 		login_token
     *  return:
     * 		access_token:
     * 		login_token:
     * 		uid:用户ID
     *  error:
     *  	10002:login_token无效
     *  explain:
     *  	login_token去passport获取
     *  线上:http://passport.mbalib.com/api2/loginweixin
     *  线下:http://192.168.1.12:8082/api2/loginweixin
     *
     */
    class func actionAccessToken(
                            _ success:@escaping (_ isSuccess: Bool)->(),
                            failure:@escaping (_ error: NSError)->()){
        
        let url = kKeBaseURL + "accessToken"
        
        MBACache.fetchString(key: kUserLoginToken) { (loginToken) in
            if let loginToken = loginToken {
                let params = [
                    "login_token": loginToken,
                    ]
                MBARequest<AccessTokenModel>.go(url: url, method: .post, params: params, cache: .Default, completionHandler: { (bean, error) in
                    if let bean = bean {
                        KeUserAccount.saveAccount(userAccount: bean)
                        MBACache.setString(value: bean.accessToken!, key: kUserAccessToken)
                        
                        success(true)
                    }
                    if let error = error {
                        failure(error)
                        if 10002 == error.code { // logintoken 过期
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUserShouldLoginNotification), object: nil, userInfo: nil)
                        }
                    }
                })
                
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUserShouldLoginNotification), object: nil, userInfo: nil)
            }
        }
    }
}


extension KeService {

    /**
     * action:SaveCourse(课程操作)
     *
     * parameter：
     * 		cid:课程id(有则表示修改，无则创建)
     * 		title:课程标题
     * 		access_token: 用户令牌
     *
     * return：
     * 		{"state":"success","cid":"8571573"}
     *
     * error:
     * 		40201:课程标题不能为空
     * 		40202:课程标题不能超过50字
     * 		40203:权限不足
     * 		40204:创建课程失败
     * 		40205:更新失败
     */
    class func actionSaveCourse(title: String,
                                cid: String? = "",
                              success:@escaping (_ bean: SaveCourseModel)->(),
                              failure:@escaping (_ error: NSError)->())
    {
        let url = kKeBaseURL + "saveCourse"
        var params = [
            "title": title
        ]
        if !(cid?.isEmpty ?? true){ // cid 不为空，修改
            params["cid"] = cid
        }
        
        MBARequest<SaveCourseModel>.goSafe(url: url, method: .post, params: params, cache: .Default, completionHandler:{ (bean, error) in
            if let bean = bean {
                success(bean)
            }
            if let error = error {
                failure(error)
            }
        })
    }
    

    /**
     * action:GetCourses(获取课程)
     *
     * parameter:
     * 		start:当前课程数量
     * 		num:每页展示的数量	可选  默认10条
     * 		access_token: 用户令牌
     *
     * return:
     *		{"state":"success","data":[{"cid":8571441,"title":"111111","state":"enable","createtime":"20170116141820"},{},....]}
     *
     * error:
     * 		40301:暂无课程数据
     */    
    class func actionGetCourses(start: Int,
                                num: Int,
                                success:@escaping (_ bean: GetCoursesModel)->(),
                                failure:@escaping (_ error: NSError)->())
    {
        let url = kKeBaseURL + "getCourses"
        let params = [
            "start": start,
            "num": num
        ]
        MBARequest<GetCoursesModel>.goSafe(url: url, method: .post, params: params, cache: .Default, completionHandler:{ (bean, error) in
            if let bean = bean {
                success(bean)
            }
            if let error = error {
                failure(error)
            }
        })
    }
    
    /**
     * action:GetMaterials(获取课程章节)
     *
     * parameter:
     * 		cid:课程ID
     * 		access_token: 用户令牌
     *
     * return：
     *		{"state":"success","data":[{"mid":"63","title":"app\u63a5\u53e3\u6d4b\u8bd5\u7ae0\u82821.1","time":"464"},{},....]}
     * error:
     *		40501:参数错误
     * 		40502:权限不足
     *		40503:暂无章节
     */
    class func actionGetMaterials(cid: String,
                                  success:@escaping (_ bean: GetMaterialsModel)->(),
                                  failure:@escaping (_ error: NSError)->())
    {
        let url = kKeBaseURL + "getMaterials"
        let params = [
            "cid": cid
        ]
        MBARequest<GetMaterialsModel>.goSafe(url: url, method: .post, params: params, cache: .Default, completionHandler:{ (bean, error) in
            if let bean = bean {
                success(bean)
            }
            if let error = error {
                failure(error)
            }
        })
    }
    
    /**
     * action:Material(章节标题操作)
     *
     * parameter:
     * 		cid:课程ID
     * 		mid:章节ID
     * 		title:章节标题
     * 		access_token: 用户令牌
     *
     * return:
     * 		{"state":"success","mid":63}
     *
     * error:
     * 		40401:参数错误
     * 		40402:章节标题不能超过50字
     * 		404031:权限不足
     * 		404032:权限不足
     * 		40404:创建章节失败
     * 		40405:更新失败
     */
    class func actionMaterial(mid: String? = "", // mid空保存，不为空修改
                              cid: String,
                              title: String,
                                success:@escaping (_ bean: SaveMaterialsModel)->(),
                                failure:@escaping (_ error: NSError)->())
    {
        let url = kKeBaseURL + "material"
        var params = [
            "cid": cid,
            "title": title
        ]
        if !(mid?.isEmpty ?? true){
            params["mid"] = mid
        }
        
        MBARequest<SaveMaterialsModel>.goSafe(url: url, method: .post, params: params, cache: .Default, completionHandler:{ (bean, error) in
            if let bean = bean {
                success(bean)
            }
            if let error = error {
                failure(error)
            }
        })
    }
    
    

    
    /**
     * action:MaterialSort(章节排序)
     *
     * parameter:
     * 		sort:[{"mid":62,"val":1},{"mid":63,"val":2},{},....]
     * 		access_token: 用户令牌
     *
     * return:
     *		{"state":"success"}
     *
     * error:
     * 		40601:参数错误
     * 		40602:排序失败
     */
    class func actionMaterialSort(cid: String,
                                  sort: [String],
                                  success:@escaping (_ bean: StatusModel)->(),
                                  failure:@escaping (_ error: NSError)->())
    {
        let url = kKeBaseURL + "materialSort"
        let params = [
            "cid": cid,
            "sort": sort.joined(separator: ",")
        ]
        MBARequest<StatusModel>.goSafe(url: url, method: .post, params: params, cache: .Default, completionHandler:{ (bean, error) in
            if let bean = bean {
                success(bean)
            }
            if let error = error {
                failure(error)
            }
        })
    }
    
    /**
     * action:MaterialDelete(章节删除)
     *
     * parameter:
     * 		mid:章节ID
     * 		access_token: 用户令牌
     *
     * return：
     *		{"state":"success"}
     * error:
     *		40701:参数错误
     *		40702:权限不足
     *		40703:删除失败
     */
    class func actionMaterialDelete(mid: String,
                                  success:@escaping (_ bean: StatusModel)->(),
                                  failure:@escaping (_ error: NSError)->())
    {
        let url = kKeBaseURL + "materialDelete"
        let params = [
            "mid": mid
        ]
        MBARequest<StatusModel>.goSafe(url: url, method: .post, params: params, cache: .Default, completionHandler:{ (bean, error) in
            if let bean = bean {
                success(bean)
            }
            if let error = error {
                failure(error)
            }
        })
    }
}


extension KeService {
    
    /**
     * action:UploadPicture(图片上传，支持多图上传)
     *
     * parameter:
     * 		mid:章节ID
     * 		file:文件资源
     * 		access_token: 用户令牌
     *
     * return：
     * 		{"state":"success","wid":"图片id"}
     *
     * error:
     * 		40801：参数错误
     * 		40802：权限不足
     * 		40803：上传失败
     */
    class func actionUploadPicture(mid: String,
                                 file: Data,
                                 success:@escaping (_ bean: UploadPictureModel)->(),
                                 failure:@escaping (_ error: NSError)->())
    {
        let url = kKeBaseURL + "uploadPicture"
        //        [["time": "","wid": ""]]
        let params = [
            "mid": mid,
            "file": file
            ] as [String : Any]

        MBARequest<UploadPictureModel>.goSafeUpload(url: url, params: params, dataType: .img, showHUD: false) { (bean, error) in
            if let bean = bean {
                success(bean)
            }
            if let error = error {
                failure(error)
            }
        }
    }

    
    /**
     * action:recordAudio
     *
     * parameter:
     * 		access_token:
     * 		mid:章节ID
     * 		file:上传的语音文件
     * 		time:语音时长
     * 		ware:[{"time":时间点,"wid":图片ID},{},.....]
     *
     * return:
     * 		{state:success,audio:语音链接}
     *
     * error:
     *		401001:参数错误
     *		401002:权限不足
     *		401003:更新音频失败
     *		401004:上传音频失败
     */
    class func actionRecordAudio(mid: String,
                                 fileURL: URL,
//                                file: Data,
                                time: String,
//                                ware: [[String: Any]]? = nil,
                                ware:String? = nil,
                                success:@escaping (_ bean: RecordAudioModel)->(),
                                failure:@escaping (_ error: NSError)->())
    {
        let url = kKeBaseURL + "recordAudio"

        let mp3Data = try? Data(contentsOf: fileURL)
        var params = [
            "mid": mid,
            "file": mp3Data!,
            "time": time
            ] as [String : Any]
        if !(ware?.isEmpty ?? true) {
            params["ware"] = ware!
        }
        
//        if !NetworkTool.isReachable() {
//            MBAToast.show(text: kNetWorkDontUseUpload)
//            params["file"] = fileURL.lastPathComponent
//            MBACache.setJson(value: params, key: "uploadError")
//        }
 
        MBARequest<RecordAudioModel>.goSafeUpload(url: url, params: params, showHUD: false) { (bean, error) in
            if let bean = bean {
                MBACache.removeJson(key: "uploadError")
                success(bean)
            }
            if let error = error {
                params["file"] = fileURL.lastPathComponent
                MBACache.setJson(value: params, key: "uploadError")
                failure(error)
            }
        }
    }
}
