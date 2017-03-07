//
//  MainViewController.swift
//  FMDemo
//
//  Created by mba on 17/2/9.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit

fileprivate var barHeight: CGFloat = 60
class MainViewController: BaseViewController {
    
    var mainTb = MainTableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - NAVIGATION_AND_STATUSBAR_HEIGHT))
    
//    @IBOutlet weak var mainTb: MainTableView!
    override func setupUI() {
        
        title = "智库课堂导师版"
        view.insertSubview(mainTb, at: 0)
        mainTb.parentVC = self
        mainTb.initWithParams("MainTableViewCell", heightForRowAtIndexPath: 100, canLoadRefresh: true, canLoadMore: true)
        mainTb.separatorStyle = .none
        mainTb.backgroundColor = UIColor.colorWithHexString(kGlobalBgColor)

        NotificationCenter.default.addObserver(self, selector: #selector(userLogin(n:)), name: NSNotification.Name(rawValue: kUserShouldLoginNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !KeUserAccount.hasAccessToken {
            MBARequest.postLoginNotification()
            return
        }
   
        mainTb.start(true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 监听方法
    func userLogin(n: Notification) {
        mainTb.dataList?.removeAll()
        //清除账号
        KeUserAccount.cleanAccount()
        let loginVC = LoginViewController()
        self.navigationController?.present(loginVC, animated: false, completion: nil)
//        self.present(loginVC, animated: false, completion: nil)
    }
}

extension MainViewController {
    

}

extension MainViewController {

    func pushCourseDetailVC(cid: String, title: String) {
        let courceMainVC = CourceMainViewController()
        courceMainVC.cid = cid
        courceMainVC.creatTitle = title
        navigationController?.pushViewController(courceMainVC, animated: true)
    }
    
    func pushPlayCourseVC(url: String) {
        let playCourseVC = PlayCourceMaterialViewController()
        playCourseVC.url = url
        playCourseVC.isMaterial = false
        navigationController?.pushViewController(playCourseVC, animated: true)
    }
}


