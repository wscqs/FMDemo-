//
//  UINavigation+Extension.swift
//  FMDemo
//
//  Created by mba on 17/3/9.
//  Copyright © 2017年 mbalib. All rights reserved.
//
import UIKit

/// 对UIView的扩展
extension UINavigationController {
    
    /// 导航控制器移除vc
    ///
    /// - Parameter viewController: 需要被移除的vc
    func remove(viewController: UIViewController) {
        for i in 0 ..< self.viewControllers.count {
            if viewController === self.viewControllers[i] {
                self.viewControllers.remove(at: i)
                break
            }
        }
    }
}
