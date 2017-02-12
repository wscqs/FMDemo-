//
//  BaseViewController.swift
//  ban
//
//  Created by mba on 16/7/28.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = UIRectEdge()
        extendedLayoutIncludesOpaqueBars = false
        automaticallyAdjustsScrollViewInsets = false
        
        view.backgroundColor = UIColor.colorWithHexString(kGlobalBgColor)
        
        if checkParams() {
            setupUI()
        }
    }
    
    /**
     检查调用本类必需传递的参数条件是否满足
     默认返回true，在需要的类中重写此方法即可
     
     - returns: true为满足
     */
    func checkParams() -> Bool{
        return true
    }
    
    
    /**
     加载数据，请求接口或者读取本地
     子类可不重写，默认调用初始化界面方法
     */
    func loadData() {
        setupUI()
    }
    
    /**
     初始化界面，在这里可以分为几个方法函数来调用
     */
    func setupUI() {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
