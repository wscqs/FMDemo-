//
//  SettingViewController.swift
//  FMDemo
//
//  Created by mba on 17/2/12.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit

class SettingViewController: BaseViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        MBACache.fetchString(key: kUserAvator) { (headimgurl) in
//            self.userImageView.qs_setImageFromUrl(headimgurl ?? "", placeholder: #imageLiteral(resourceName: "course_chapt_state1_ico"), isAvatar: true)
//        }
//        MBACache.fetchString(key: kUserName) { (nickname) in
//            self.userNameLabel.text = nickname
//        }
        self.userImageView.qs_setImageFromUrl(KeUserAccount.shared?.avatar ?? "", placeholder: #imageLiteral(resourceName: "course_chapt_state1_ico"), isAvatar: true)
        self.userNameLabel.text = KeUserAccount.shared?.nickname
    }
    
    
    @IBAction func actionExitUser(_ sender: UIButton) {
        //清除账号
        KeUserAccount.cleanAccount()
        _ = navigationController?.popToRootViewController(animated: false)
    }
    
}
