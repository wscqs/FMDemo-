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
    
    var mainTb = CourceMainTableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - NAVIGATION_AND_STATUSBAR_HEIGHT))
    var creatTitle: String!
    var cid: String!
    
    override func setupUI() {
        title = "课程主页"
        view.addSubview(mainTb)
        mainTb.parentVC = self
        
        mainTb.initWithParams("CourceMainTableViewCell", heightForRowAtIndexPath: 85, canLoadRefresh: true, canLoadMore: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if creatTitle.isEmpty && cid.isEmpty {
            print("CourceMainViewController ，cid或标题为空！")
        }
        
        mainTb.setcid(cid: cid, title: creatTitle)
        mainTb.start(true)
    }
 
}


// MARK: - push
extension CourceMainViewController {
    func pushToRecordViewController(mid: String) {
        let recordVC = UIStoryboard(name: "Record", bundle: nil).instantiateInitialViewController() as? RecordViewController
        recordVC?.mid = mid
        self.navigationController?.pushViewController(recordVC!, animated: true)
    }
    
    func pushToPlayCourceMaterialViewController(url: String) {
        let playCourceMaterialVC = PlayCourceMaterialViewController()
        playCourceMaterialVC.url = url
        self.navigationController?.pushViewController(playCourceMaterialVC, animated: true)
    }
}
