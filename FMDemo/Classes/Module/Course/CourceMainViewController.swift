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
    
    override func setupUI() {
        mainTb.parentVC = self
    }
}
