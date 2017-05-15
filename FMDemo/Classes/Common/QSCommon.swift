//
//  QSUICommon.swift
//  QSBaoKan
//
//  Created by mba on 16/6/7.
//  Copyright © 2016年 cqs. All rights reserved.
//

import UIKit

let kWaveTime = 0.2
let kUserShouldLoginNotification = "kUserShouldLoginNotification"
let kUserAccessToken = "kUserAccessToken"
let kUserLoginToken = "kUserLoginToken"

let kCreatCourceTitleString = "请输入课程标题，不要超过50个中文字符"
let kCreatMaterialTitleString = "请输入章节标题，不要超过50个中文字符"


let kNetWorkDontUseUpload = "当前网络不可用，无法上传"
let kNetWorkErrorUpload = "网络状态不佳，请重新上传"


// MARK: UI
/// 屏幕bounds
let SCREEN_BOUNDS = UIScreen.main.bounds

/// 屏幕size
let SCREEN_SIZE = UIScreen.main.bounds.size

/// 屏幕width
let SCREEN_WIDTH = UIScreen.main.bounds.size.width

/// 屏幕height
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

/// 导航栏高度
let NAVIGATIONBAR_HEIGHT: CGFloat = 44.0

/// 状态栏高度
let STATUSBAR_HEIGHT: CGFloat = 20.0

/// 导航栏与状态栏总高度
let NAVIGATION_AND_STATUSBAR_HEIGHT: CGFloat = 64.0

/// tabbar 高度
let TABBAR_HEIGHT: CGFloat = 49.0

/// 全局边距
let MARGIN: CGFloat = 12

/// 全局圆角
let CORNER_RADIUS: CGFloat = 5

// MARK: - Color
/// 导航栏背景颜色 - （红色）
let NAVIGATIONBAR_RED_COLOR = UIColor(red:0.831,  green:0.239,  blue:0.243, alpha:1)
/// 导航栏背景颜色 - (白色)
let NAVIGATIONBAR_WHITE_COLOR = UIColor.colorWithRGB(244, g: 244, b: 244)
/// 控制器背景颜色
let BACKGROUND_COLOR = UIColor(red:0.933,  green:0.933,  blue:0.933, alpha:1)

/// 全局背景
let Color_GlobalBackground = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0)
let Color_GlobalLine = UIColor(red: 237.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0)

// MARK: - TableView
let CELLID = "cellId"

let TABLEVIEW_HEADTITLR_HEIGHT: CGFloat = 30

let TABLEVIEW_TITLE_HEIGHT: CGFloat = 10


// MARK: - CGRect
/// 从0少了Navi高度and Status高度
let CGRE0SN = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - NAVIGATION_AND_STATUSBAR_HEIGHT)
/// 从0少了Navi与Status和Tab高度
let CGRE0SNT = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - NAVIGATION_AND_STATUSBAR_HEIGHT - TABBAR_HEIGHT)
