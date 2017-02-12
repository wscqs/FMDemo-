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
            guard let pointArray = pointArray else {
                return
            }
            setNeedsDisplay()
        }
    }
    
    var slider: UISlider = UISlider()
    
    /// 边框及底部颜色
    var waveBackgroundColor = UIColor.black {
        didSet {
            layer.borderWidth = 3.0
            layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
            backgroundColor = waveBackgroundColor
            setNeedsDisplay()
        }
    }
    
    /// 声波的颜色
    var waveStrokeColor = UIColor.lightGray {
        didSet {
            
        }
    }
    
    var waveHightStrokeColor = UIColor.orange {
        didSet {
            
        }
    }
    
    var widthScaling: CGFloat = 1.0
    let heightScaling: CGFloat = 0.9
    

    
    var kLineWidth:CGFloat = 2.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clearsContextBeforeDrawing = true
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setupView() {
        frame = bounds
        backgroundColor = waveBackgroundColor
        layer.cornerRadius = 2.0
        layer.masksToBounds = true
        
        addSubview(slider)
        slider.setThumbImage(UIImage(named: "line"), for: .normal)
        
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let pointArray = pointArray  else {
            return
        }
        if pointArray.count == 0 {return}

        // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let boundsH = self.bounds.size.height
        let boundsW = self.bounds.size.width
        
        if CGFloat(pointArray.count * 4) > boundsW {
            widthScaling = boundsW / CGFloat(pointArray.count * 4)
        }
        
        
        //3. 设置画布的缩放和上下左右间距
//        context.scaleBy(x: widthScaling, y: heightScaling)
//        let xOffset = bounds.size.width - (bounds.size.width * widthScaling)
//        let yOffset = bounds.size.height - (bounds.size.height * heightScaling)
//        context.translateBy(x: boundsW / 2, y: boundsH / 2) 
        
        kLineWidth = kLineWidth * widthScaling
        context.setLineWidth(kLineWidth)
        let spaceW = kLineWidth * 2
        for i in 0 ..< pointArray.count {
            let x = CGFloat(i) * spaceW
            context.move(to: CGPoint(x: x, y: boundsH))
            context.addLine(to: CGPoint(x: x, y: boundsH * (1 - pointArray[i])))
        }

        slider.frame = CGRect(x: 0, y: 0, width: CGFloat(pointArray.count) * spaceW , height: boundsH)
        
        let numberOfSteps = pointArray.count
        slider.maximumValue = Float(numberOfSteps)
        slider.minimumValue = 0
        slider.value = 0

        context.setAlpha(1.0)
        context.setShouldAntialias(true) // 去除锯齿
        context.setStrokeColor(self.waveStrokeColor.cgColor)
        context.setFillColor(self.waveStrokeColor.cgColor)
        context.strokePath()

        let maxiTrackImage = UIGraphicsGetImageFromCurrentImageContext()
        
        context.setFillColor(self.waveHightStrokeColor.cgColor)
        UIRectFillUsingBlendMode(bounds, .sourceAtop)
        
        let minxTrackImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        slider.setMaximumTrackImage(maxiTrackImage?.resizableImage(withCapInsets: .zero), for: .normal)
        slider.setMinimumTrackImage(minxTrackImage?.resizableImage(withCapInsets: .zero), for: .normal)
        
        // 透明图像
        //        UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), false, 0.0)
        //        let transparentImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        //        UIGraphicsEndImageContext()
        
    }
    
}

