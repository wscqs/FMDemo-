//
//  QSNavigationController.swift
//  QSBaoKan
//
//  Created by mba on 16/6/7.
//  Copyright © 2016年 cqs. All rights reserved.
//

import UIKit

class QSNavigationController: UINavigationController, UIGestureRecognizerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()

        self.interactivePopGestureRecognizer!.delegate = nil
        // 禁用左滑动返回
        interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    lazy var backBtn: UIButton = UIButton(imageName:"nav_details_top_left", backTarget: self, action: #selector(QSNavigationController.backBtnAction))
//    lazy var homeBtn: UIButton = UIButton(imageName:"nav_home", backTarget: self, action: #selector(QSNavigationController.popToRootAction))
    
    func backBtnAction() {
        _ = popViewController(animated: true)
    }
    
    func popToRootAction() {
        _ = popToRootViewController(animated: true)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {

        if childViewControllers.count > 0 {
            backBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: -3, bottom: 0, right: 0)
            backBtn.adjustsImageWhenHighlighted = false
            
            viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
//            viewController.hidesBottomBarWhenPushed = true
//            if childViewControllers.count > 1 {
//                homeBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
//                viewController.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: backBtn),UIBarButtonItem(customView: homeBtn)]
//            }
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        return super.popViewController(animated: animated)
    }

}
