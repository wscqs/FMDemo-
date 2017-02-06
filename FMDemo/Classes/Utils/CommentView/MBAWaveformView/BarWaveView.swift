//
//  BarWaveView.swift
//  FMDemo
//
//  Created by mba on 17/1/19.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit

class BarWaveView: UIView {
    
    var pointArray: Array<CGFloat>? {
        didSet{
            setNeedsDisplay()
        }
    }
    
    var kLineWidth:CGFloat = 2.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clearsContextBeforeDrawing = true
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")      
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
 
    override func draw(_ rect: CGRect) {
        
        guard let pointArray = pointArray  else {
            return
        }
        if pointArray.count == 0 {return}
        
        UIRectFill(bounds)
        
        let cgContext = UIGraphicsGetCurrentContext()
        cgContext?.setLineWidth(kLineWidth)
        cgContext?.beginPath()
        cgContext?.setStrokeColor(UIColor.lightGray.cgColor)
        let height = self.bounds.size.height
        for i in 0 ..< pointArray.count {
            cgContext?.move(to: CGPoint(x: self.bounds.size.width - CGFloat(i) * kLineWidth * 2, y: height))
            cgContext?.addLine(to: CGPoint(x: self.bounds.size.width - CGFloat(i) * kLineWidth * 2, y: height * (1 - pointArray[i])))
        }
        
        cgContext?.strokePath()
        
    }

}
