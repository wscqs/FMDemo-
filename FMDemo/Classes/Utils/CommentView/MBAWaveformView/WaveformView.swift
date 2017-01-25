//
//  SampleDataProvider.swift
//  WaveformView
//
//  Created by XB on 16/8/10.
//  Copyright © 2016年 XB. All rights reserved.
//

import UIKit
import AVFoundation

class WaveformView: UISlider {

    open var url: URL? {
        didSet {
            guard let url = url else { return }
            asset = AVAsset(url: url)
        }
    }
    
    fileprivate var asset: AVAsset? {
        didSet {
            guard let asset = asset else { return }
            //从资源中获取到样本数据后进行绘制
            SampleDataProvider.loadAudioSamplesFormAsset(asset){sampleData in
                self.filter = SampleDataFilter(sampleData: sampleData)
                self.loadingView.stopAnimating()
                self.setNeedsDisplay()
            }
        }
    }

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
    var waveStrokeColor = UIColor.gray {
        didSet {
            
        }
    }
    
    var waveHightStrokeColor = UIColor.orange {
        didSet {
            
        }
    }

    let widthScaling: CGFloat = 1.0
    let heightScaling: CGFloat = 0.9
    
    var filter: SampleDataFilter?
    var loadingView: UIActivityIndicatorView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setupView() {
        frame = bounds
        backgroundColor = waveBackgroundColor
        layer.cornerRadius = 2.0
        layer.masksToBounds = true

        loadingView = UIActivityIndicatorView(activityIndicatorStyle:.whiteLarge)
        addSubview(loadingView)
        loadingView.startAnimating()

        let size = loadingView.frame.size
        let x = (bounds.width - size.width) / 2.0
        let y = (bounds.height - size.height) / 2.0
        loadingView.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        
        setThumbImage(UIImage(named: "line"), for: .normal)
    }
    
    var kLineWidth:CGFloat = 2.0
    override func draw(_ rect: CGRect) {
        
        UIGraphicsBeginImageContext(bounds.size)
        //1. 获取绘图上下文
        guard let context = UIGraphicsGetCurrentContext() else { return }
        //2. 获取需要进行绘制的数据
        guard let filteredSamples = filter?.filteredSamplesForSize(bounds.size) else {
            return
        }
        //3. 设置画布的缩放和上下左右间距
        context.scaleBy(x: widthScaling, y: heightScaling)
        let xOffset = bounds.size.width - (bounds.size.width * widthScaling)
        let yOffset = bounds.size.height - (bounds.size.height * heightScaling)
        context.translateBy(x: xOffset / 2, y: yOffset / 2)
        for i in 0..<filteredSamples.count {
            let sample = CGFloat(filteredSamples[i])
            let x = CGFloat(i) * kLineWidth * 2
            context.move(to: CGPoint(x: x, y: rect.height))
            context.addLine(to: CGPoint(x: x, y: rect.height - sample))
        }
        context.setAlpha(1.0)
        context.setShouldAntialias(false)
        context.setStrokeColor(self.waveStrokeColor.cgColor)
        context.setFillColor(self.waveStrokeColor.cgColor)
        context.strokePath()
        
        let maxiTrackImage = UIGraphicsGetImageFromCurrentImageContext()
        
        context.setFillColor(self.waveHightStrokeColor.cgColor)
        UIRectFillUsingBlendMode(bounds, .sourceAtop)

        let minxTrackImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        setMaximumTrackImage(maxiTrackImage?.resizableImage(withCapInsets: .zero), for: .normal)
        setMinimumTrackImage(minxTrackImage?.resizableImage(withCapInsets: .zero), for: .normal)
        
    }
    
    //    // 波纹风格
    //    func sliceStyle(rect: CGRect,filteredSamples: [Float], context: CGContext) {
    //        //4. 绘制上半部分
    //        let midY = rect.midY
    //        let halfPath = CGMutablePath()
    //        halfPath.move(to: CGPoint(x: 0, y: midY))
    //
    //        for i in 0..<filteredSamples.count {
    //            let sample = CGFloat(filteredSamples[i])
    //            halfPath.addLine(to: CGPoint(x: CGFloat(i), y: midY - sample))
    //        }
    //        halfPath.addLine(to: CGPoint(x: CGFloat(filteredSamples.count), y: midY))
    //
    //        //5. 绘制下半部分,对上半部分进行translate和sacle变化,即翻转上半部分
    //        let fullPath = CGMutablePath()
    //        fullPath.addPath(halfPath)
    //        var transform = CGAffineTransform.identity
    //        transform = transform.translatedBy(x: 0, y: rect.height);
    //        transform = transform.scaledBy(x: 1.0, y: -1.0);
    //        fullPath.addPath(halfPath, transform:transform)
    //
    //        //6. 将完整路径添加到上下文
    //        context.addPath(fullPath);
    //        context.setFillColor(self.waveBackgroundColor.cgColor)
    //        context.drawPath(using: .fill)
    //    }

}

