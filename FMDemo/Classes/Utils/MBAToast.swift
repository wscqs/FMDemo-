//
//  MBAToast.swift
//  bang
//
//  Created by mba on 16/10/13.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import UIKit
import Toaster

class MBAToast: Toast {
    
    class func show(text: String,delay: TimeInterval = 0,duration: TimeInterval = 1) {
        _ = Toast(text: text, delay: delay, duration: duration).show()
    }
}
