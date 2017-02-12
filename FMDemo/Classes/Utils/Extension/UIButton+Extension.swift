//
//  UIButton+Extension.swift
//  Liwushuo
//
//  Created by hans on 16/6/30.
//  Copyright © 2016年 汉斯哈哈哈. All rights reserved.
//

import UIKit

extension UIButton {
    
    convenience init(imageName: String, backImageName: String) {
        self.init()
        setImage(UIImage(named: imageName), for: .normal)
        setBackgroundImage(UIImage(named: backImageName), for: .normal)
        sizeToFit()
    }
    
    convenience init(title: String,
                     fontSize: CGFloat = 16,
                     normalColor: UIColor = .darkGray,
                     highlightedColor: UIColor = .orange,
                     imageName: String? = "",
                     //                     highlightedImageName: String?,
        isBack: Bool = false) {
        self.init()
        
        setTitle(title, for: .normal)
        setTitleColor(normalColor, for: .normal)
        setTitleColor(highlightedColor, for: .highlighted)
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        if let imageName = imageName{
            setImage(UIImage(named: imageName), for: .normal)
            setImage(UIImage(named: imageName + "_highlighted"), for: .highlighted)
        }
        //        if let highlightedImageName = highlightedImageName {
        //            setImage(UIImage(named: highlightedImageName), for: .highlighted)
        //        }
        
        if isBack {
            let imageName = "back"
            setImage(UIImage(named: imageName), for: .normal)
            setImage(UIImage(named: imageName + "_highlighted"), for: .highlighted)
        }
        sizeToFit()
    }
    
    convenience init(imageName: String, backTarget: AnyObject?, action: Selector) {
        self.init()
        setImage(UIImage(named: imageName), for: UIControlState())
        frame = CGRect(x: 0, y: 0, width: 44.0, height: 44.0)
        contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        addTarget(backTarget, action: action, for: UIControlEvents.touchUpInside)
    }
}
