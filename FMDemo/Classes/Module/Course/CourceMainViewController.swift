//
//  CourceViewController.swift
//  FMDemo
//
//  Created by mba on 17/2/9.
//  Copyright © 2017年 mbalib. All rights reserved.
//
// 课程主页

import UIKit

class CourceMainViewController: BaseViewController {
    
    @IBOutlet weak var mainTb: CourceMainTableView!
    var creatTitle: String!
    
    override func setupUI() {
        
//        NotificationCenter.default.addObserver(self, selector: #selector(userLogin(n:)), name: NSNotification.Name(rawValue: kUserShouldLoginNotification), object: nil)
        
        

    }
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
    
//    // MARK: - 监听方法
//    @objc private func userLogin(n: Notification) {
//        //清除账号
//        KeUserAccount.cleanAccount()
//        let loginVC = LoginViewController()
//        self.present(loginVC, animated: true, completion: nil)
//    }
//    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainTb.parentVC = self
        mainTb.tbHeadView.titleLabel.text = creatTitle
    }
}


extension CourceMainViewController {
    func pushToRecordViewController() {
        let recordVC = UIStoryboard(name: "Record", bundle: nil).instantiateInitialViewController()
        self.navigationController?.pushViewController(recordVC!, animated: true)
    }
}
