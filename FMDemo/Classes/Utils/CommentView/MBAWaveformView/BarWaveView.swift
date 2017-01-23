//
//  BarWaveView.swift
//  FMDemo
//
//  Created by mba on 17/1/19.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit
import AVFoundation

class BarWaveView: UIView {
    
    var pointArray: Array<CGPoint>? {
        didSet{
            setNeedsDisplay()
        }
    }
    
    var kLineWidth:CGFloat = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clearsContextBeforeDrawing = true
    }
 
    override func draw(_ rect: CGRect) {
        
        guard let pointArray = pointArray  else {
            return
        }
        if pointArray.count == 0 {return}
        
        let cgContext = UIGraphicsGetCurrentContext()
        cgContext?.setLineWidth(kLineWidth)
        cgContext?.beginPath()
        cgContext?.setStrokeColor(UIColor.orange.cgColor)
        for i in 0 ..< pointArray.count {
            cgContext?.move(to: CGPoint(x: self.bounds.size.width - CGFloat(i) * kLineWidth * 2, y: self.bounds.size.height))
            cgContext?.addLine(to: CGPoint(x: self.bounds.size.width - CGFloat(i) * kLineWidth * 2, y: pointArray[i].y))
        }
        
        cgContext?.strokePath()
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
