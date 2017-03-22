//
//  BarWaveView.swift
//  FMDemo
//
//  Created by mba on 17/1/19.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit

class PlayBarWaveView: UIView {
    
    var pointXArray: Array<CGFloat>? {
        didSet{
            guard let pointXArray = pointXArray else {
                return
            }
            print(pointXArray.count)
            slider.maximumValue = Float(pointXArray.count)
            setNeedsDisplay()
        }
    }
    
    var isRenderSucess: ((_ resulet: Bool) -> Void)?
    
    var slider: UISlider = NoGapSlider()
    
    /// 边框及底部颜色
    var waveBackgroundColor = UIColor.colorWithHexString("2b95ff") {
        didSet {
            layer.borderWidth = 3.0
            layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
            backgroundColor = waveBackgroundColor
            setNeedsDisplay()
        }
    }
    
    /// 声波的颜色.colorWithHexString("2e80d1")
    var waveStrokeColor = UIColor.colorWithHexString("2e80d1") {
        didSet {
            
        }
    }
    
    var waveHightStrokeColor = UIColor.white {
        didSet {
            
        }
    }
    
    var widthScaling: CGFloat = 1.0
    let heightScaling: CGFloat = 0.9
    

    
    var kLineWidth:CGFloat = 2.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setupView() {
        self.clearsContextBeforeDrawing = true
        frame = bounds
        backgroundColor = waveBackgroundColor
        layer.cornerRadius = 3.0
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGray.cgColor
        layer.masksToBounds = true
        
        addSubview(slider)
        slider.setThumbImage(#imageLiteral(resourceName: "record_volume_control_ico"), for: .normal)
        slider.minimumValue = 0
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let pointXArray = pointXArray  else {
            return
        }
        if pointXArray.count == 0 {return}
        
        // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setAlpha(1)
        context.setShouldAntialias(true) // 去除锯齿
        
        let spaceTop: CGFloat = 2
        let boundsH = self.bounds.size.height - spaceTop
        let boundsW = self.bounds.size.width
        let spaceW = kLineWidth * 2
        
        
        if CGFloat(pointXArray.count) * spaceW > boundsW {
            widthScaling = boundsW / (CGFloat(pointXArray.count) * spaceW)
            print(widthScaling)
            context.scaleBy(x: widthScaling, y: 1)
            slider.frame = CGRect(x: 0, y: 6,  width: boundsW , height: boundsH - 4)
        } else {
            slider.frame = CGRect(x: 0, y: 6,  width: CGFloat(pointXArray.count) * spaceW , height: boundsH - 4)
        }
        let numberOfSteps = pointXArray.count
        slider.maximumValue = Float(numberOfSteps)
        slider.minimumValue = 0
        slider.value = 0
        
        context.setLineWidth(kLineWidth)
        for i in 0 ..< pointXArray.count {
            let x = CGFloat(i) * spaceW
            context.move(to: CGPoint(x: x, y: boundsH))
            context.addLine(to: CGPoint(x: x, y: boundsH * (1 - pointXArray[i])))
        }
        context.setStrokeColor(self.waveStrokeColor.cgColor)
        context.strokePath()
        
        
        let minxTrackImage = UIGraphicsGetImageFromCurrentImageContext()
        
        guard let context1 = UIGraphicsGetCurrentContext() else { return }
        context1.setAlpha(1)
        context1.setShouldAntialias(true) // 去除锯齿
        for i in 0 ..< pointXArray.count {
            let x = CGFloat(i) * spaceW
            context1.move(to: CGPoint(x: x, y: boundsH))
            context1.addLine(to: CGPoint(x: x, y: boundsH * (1 - pointXArray[i])))
        }
        context1.setStrokeColor(self.waveHightStrokeColor.cgColor)
        context1.strokePath()
        
        let maxiTrackImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        slider.setMaximumTrackImage(minxTrackImage?.resizableImage(withCapInsets: .zero), for: .normal)
        slider.setMinimumTrackImage(maxiTrackImage?.resizableImage(withCapInsets: .zero), for: .normal)
        
        isRenderSucess?(true)
    }
}

// MARK: - open API
extension PlayBarWaveView {
    /// 传入播放的进度
    func setPlayProgress(thumbPointXIndex :Int) {
        slider.setValue(Float(thumbPointXIndex), animated: true)
    }
}

