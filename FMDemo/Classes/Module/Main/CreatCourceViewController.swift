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
    override func viewDidLoad() {
        creatCourceTextView.setPlaceholder("请输入课程标题，不要超过50个中文字符", maxTip: 50)
    }
    
    @IBAction func actionNext(_ sender: UIButton) {
        
        print(creatCourceTextView.text)
    }

    
}