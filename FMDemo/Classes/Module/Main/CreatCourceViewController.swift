//
//  CreatCourceViewController.swift
//  FMDemo
//
//  Created by mba on 17/2/10.
//  Copyright © 2017年 mbalib. All rights reserved.
//
// 创建课程

import UIKit

class CreatCourceViewController: UIViewController {

    @IBOutlet weak var creatCourceTextView: BorderTextView!
    var cid:String?
    
    override func viewDidLoad() {
        creatCourceTextView.setPlaceholder("请输入课程标题，不要超过50个中文字符", maxTip: 50)
    }
    
    var isRequest: Bool = false
    @IBAction func actionNext(_ sender: UIButton) {
        if creatCourceTextView.text.isEmpty {
            MBAProgressHUD.showInfoWithStatus("创建课程标题不能为空")
            return
        }
        
        if isRequest {
            return
        }
        
        isRequest = true
        
        KeService.actionSaveCourse(title: creatCourceTextView.text, success: { (bean) in
            self.cid = bean.cid
            DispatchQueue.main.async {
                self.pushToCourceMainVC()
                self.isRequest = false
            }
        }) { (error) in
            self.isRequest = false
        }
    }
}

// MARK: - push
extension CreatCourceViewController {
    
    func pushToCourceMainVC() {
        let courceMainVC = CourceMainViewController()
        courceMainVC.creatTitle = creatCourceTextView.text
        courceMainVC.cid = self.cid!
        
        navigationController?.pushViewController(courceMainVC, animated: true)

        // 跳转后控制器移除自己
        navigationController?.remove(viewController: self)
    }
}

