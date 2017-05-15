//
//  MainViewController.swift
//  FMDemo
//
//  Created by mba on 17/2/9.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit

class MainViewController: BaseViewController {
    
    var mainTb = MainTableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - NAVIGATION_AND_STATUSBAR_HEIGHT))
    
    override func setupUI() {
        
        title = "智库课堂导师版"
        view.insertSubview(mainTb, at: 0)
        mainTb.parentVC = self
        mainTb.initWithParams("MainTableViewCell", heightForRowAtIndexPath: 100, canLoadRefresh: true, canLoadMore: true)
        mainTb.separatorStyle = .none
        mainTb.backgroundColor = UIColor.colorWithHexString(kGlobalBgColor)

        NotificationCenter.default.addObserver(self, selector: #selector(userLogin(n:)), name: NSNotification.Name(rawValue: kUserShouldLoginNotification), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(shouldReLoadMainData), name: .shouldReLoadMainData, object: nil)
    }
    
    func shouldReLoadMainData() {
        mainTb.mj_header.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !KeUserAccount.hasAccessToken {
            MBARequest.postLoginNotification()
            return
        }
   
        mainTb.start(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        MBACache.fetchJson(key: "uploadError") { (uploadJson) in
            guard let fileString = uploadJson?["file"] as? String,
                let mid = uploadJson?["mid"] as? String,
                let time = uploadJson?["time"] as? String else {
                    return
            }
            
            let saveURL = URL(fileURLWithPath: fileString.docSaveRecordDir())
            let ware = uploadJson?["ware"] as? String
            
            
            let alertController = UIAlertController(title: "上传上次未成功课程", message: nil, preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "删除", style: .cancel, handler: { (action) in
                MBACache.removeJson(key: "uploadError")
            })
            
            let ok = UIAlertAction(title: "确定", style: .default, handler: { (action) in
                if !NetworkTool.isReachable() {
                    MBAToast.show(text: kNetWorkDontUseUpload)
                    return
                }
                
                MBAProgressHUD.show()
                KeService.actionRecordAudio(mid: mid, fileURL: saveURL, time: time,ware: ware, success: { (bean) in
                    MBAProgressHUD.dismiss()
                    MBAProgressHUD.showSuccessWithStatus("上传成功")                    
                }, failure: { (error) in
                    MBAProgressHUD.dismiss()
                    MBAProgressHUD.showErrorWithStatus(kNetWorkErrorUpload)
                })
            })
            alertController.addAction(cancel)
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 监听方法
    func userLogin(n: Notification) {
        mainTb.dataList?.removeAll()
        mainTb.reloadData()
        KeUserAccount.cleanAccount()
        let loginVC = LoginViewController()
        self.navigationController?.present(loginVC, animated: false, completion: nil)
    }
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


