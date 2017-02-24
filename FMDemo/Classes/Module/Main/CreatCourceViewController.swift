//
//  CreatCourceViewController.swift
//  FMDemo
//
//  Created by mba on 17/2/10.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit

class CreatCourceViewController: UIViewController {

    @IBOutlet weak var creatCourceTextView: BorderTextView!
    var cid:String?
    
    override func viewDidLoad() {
        creatCourceTextView.setPlaceholder("请输入课程标题，不要超过50个中文字符", maxTip: 50)
    }
    
    @IBAction func actionNext(_ sender: UIButton) {
        if creatCourceTextView.text.isEmpty {
            MBAProgressHUD.showInfoWithStatus("创建课程标题不能为空")
            return
        }
        
        
        KeService.actionSaveCourse(title: creatCourceTextView.text, success: { (bean) in
            self.cid = bean.cid
            DispatchQueue.main.async {
                self.preparePreEvent()
            }
        }) { (error) in}
    }
    
    
    func preparePreEvent() {
        let courceMainVC = CourceMainViewController()
        courceMainVC.creatTitle = creatCourceTextView.text
        courceMainVC.cid = self.cid!
        
        navigationController?.pushViewController(courceMainVC, animated: true)

        for i in 0 ..< (navigationController?.viewControllers.count ?? 0){
            if navigationController?.viewControllers[i] is CreatCourceViewController {
                navigationController?.viewControllers.remove(at: i)
                break
            }
        }
    }
}

