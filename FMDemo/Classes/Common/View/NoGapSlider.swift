//
//  NoGapSlider.swift
//  FMDemo
//
//  Created by mba on 17/2/15.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit

class NoGapSlider: UISlider {

    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let spaceW: CGFloat = 8.0
        let newRect = CGRect(x: rect.origin.x - spaceW, y: rect.origin.y, width: rect.size.width + spaceW * 2, height: rect.size.height)
        return  super.thumbRect(forBounds: bounds, trackRect: newRect, value: value).insetBy(dx: spaceW, dy: spaceW)
    }
}
