//
//  UILabel+Extension.swift
//  ban
//
//  Created by mba on 16/9/2.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import UIKit

extension UILabel {
    
    /**
     设置富文本
     
     - parameter text:      内容
     - parameter textColor: 内容颜色
     - parameter key:       关键字
     - parameter keyColor:  关键字颜色
     */
    func qs_setAttributedText(_ text: String, textColor: UIColor, key: String, keyColor: UIColor) {
        let attributedString = NSMutableAttributedString(string: text)
        let rang = (text as NSString).range(of: "\(key)")
        attributedString.addAttribute(NSForegroundColorAttributeName, value: keyColor, range: NSRange(location: rang.location ,length: rang.length))
        self.textColor = textColor
        attributedText = attributedString
    }
    
    
}
