//
//  UIImageView+Extension.swift
//  ban
//
//  Created by mba on 16/6/7.
//  Copyright © 2016年 cqs. All rights reserved.
//

import UIKit
import Haneke

extension UIImageView {
    
    /**
     设置图片
     
     - parameter urlString:   URLString
     - parameter placeholder: 默认图片
     */
    func qs_setImageFromUrl(_ urlString: String, placeholder: UIImage? = UIImage(named: "none"), isAvatar: Bool = false) {
        
        guard let url = URL(string: urlString) else {
            image = placeholder
            return
        }
        
        let iconFormat = Format<UIImage>(name: "icons", diskCapacity: 10 * 1024 * 1024) { image in
            if isAvatar {
                return image.qs_avatarImage(size: self.bounds.size)!
            } else {
                return image
            }
        }
        
        hnk_setImageFromURL(url, placeholder: placeholder, format: iconFormat, failure: nil, success: nil)

    }

}
