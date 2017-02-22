//
//  SettingViewController.swift
//  FMDemo
//
//  Created by mba on 17/2/12.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit
import WechatKit

class SettingViewController: BaseViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userImageView.qs_setImageFromUrl(WechatUser.shared?.headimgurl ?? "", placeholder: #imageLiteral(resourceName: "course_chapt_state1_ico"), isAvatar: true)
        userNameLabel.text = WechatUser.shared?.nickname
    }
    
    
    @IBAction func actionExitUser(_ sender: UIButton) {
        AccessTokenModel.clearBean()
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
}
