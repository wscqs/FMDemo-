//
//  Array+Extension.swift
//  ban
//
//  Created by mba on 16/8/22.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import UIKit

extension UISegmentedControl{
    
    convenience init(items: [String],target: AnyObject?, action: Selector) {
        self.init(items: items)
        selectedSegmentIndex = 0
        
        for i in 0 ..< items.count {
            let width: CGFloat = CGFloat(SCREEN_WIDTH * 0.7) / CGFloat(items.count)
            setWidth(width, forSegmentAt: i)
        }
        
        // 选中状态
//        let seleImg = UIImage.imageWithColor(UIColor.colorWithHexString(kGlobalBlueColor), size: self.size)
//        setBackgroundImage(seleImg, for: .selected, barMetrics: UIBarMetrics.default)
        
//        var seleAttrs: [String : AnyObject] = Dictionary()
//        seleAttrs[NSForegroundColorAttributeName] = UIColor.white
//        seleAttrs[NSFontAttributeName] = UIFont.boldSystemFont(ofSize: 16)
//        setTitleTextAttributes(seleAttrs, for: .selected)
        
        addTarget(target, action: action, for: UIControlEvents.valueChanged)
    }

    
}
