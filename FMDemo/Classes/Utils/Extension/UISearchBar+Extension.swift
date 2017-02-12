//
//  UIImage+Extension.swift
//  QSBaoKan
//
//  Created by mba on 16/6/7.
//  Copyright © 2016年 cqs. All rights reserved.
//


import UIKit

extension UISearchBar {

    convenience init(searchGifdelegate: UISearchBarDelegate, backgroundColor: UIColor, backgroundImage: UIImage) {
        self.init()
        delegate = searchGifdelegate
        placeholder = "快选一份礼物，送给亲爱的Ta吧"
        tintColor = UIColor.white
        barStyle = UIBarStyle.blackTranslucent
        layer.masksToBounds = true
        layer.cornerRadius = 5.0
        self.backgroundImage = backgroundImage
        for subView in subviews {
            for subView1 in subView.subviews {
                if subView1.isKind(of: UITextField.self) {
                    subView1.backgroundColor = backgroundColor
                }
            }
            
        }
    }
}
