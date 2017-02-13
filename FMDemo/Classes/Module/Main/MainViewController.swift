//
//  MainViewController.swift
//  FMDemo
//
//  Created by mba on 17/2/9.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit
import SnapKit

fileprivate var barHeight: CGFloat = 60
class MainViewController: BaseViewController {
    
//    var mainTb = MainTableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - barHeight - NAVIGATION_AND_STATUSBAR_HEIGHT))
//    var addCourseBtn = UIButton()
    
    @IBOutlet weak var mainTb: MainTableView!
    override func setupUI() {
        setNav()
        mainTb.parentVC = self
    }
}

extension MainViewController {
    fileprivate func setNav() {
        title = "智库课堂导师版"
    }
}

extension MainViewController {
    

}

extension MainViewController {

    func pushCourseDetailVC() {
         navigationController?.pushViewController(CourceMainViewController(), animated: true)
    }
}

