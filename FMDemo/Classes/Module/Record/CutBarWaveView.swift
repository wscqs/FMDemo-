//
//  BarWaveView.swift
//  FMDemo
//
//  Created by mba on 17/1/19.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit
protocol CutBarWaveViewDelegate: NSObjectProtocol{
    func changceTimeLabel(cutBarWaveView: CutBarWaveView, centerX: CGFloat, thumbPointXIndex: Int)
}

class CutBarWaveView: UIView {
    

    
    weak var delegate: CutBarWaveViewDelegate?
    
    var pointXArray: Array<CGFloat>? {
        didSet{
            guard pointXArray != nil else {
                return
            }
            setNeedsDisplay()
        }
    }
    var minSecond: CGFloat = 3.0
    
    fileprivate var scrollView = UIScrollView()
    fileprivate var thumbBarImage: UIImageView = UIImageView()
    fileprivate var playHightView: UIView = UIView()
    fileprivate var playBackView: UIView = UIView()
    fileprivate var thumbPointXIndex: Int = 0
    
    let kLineWidth: CGFloat = 2.0
    let spaceW: CGFloat = 2.0 * 2
    
    var boundsH: CGFloat = 0
    var boundsW: CGFloat = 0
    var scrollViewContenW: CGFloat = 0
    
    /// 边框及底部颜色
    var waveBackgroundColor = UIColor.colorWithHexString("2b95ff") {
        didSet {
            layer.borderWidth = 3.0
            layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
            backgroundColor = waveBackgroundColor
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
        frame = bounds
        backgroundColor = waveBackgroundColor
        layer.cornerRadius = 3.0
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGray.cgColor
        layer.masksToBounds = true
        
        addSubview(scrollView)
        scrollView.addSubview(playBackView)
        scrollView.addSubview(playHightView)
        
        
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        
        
        addSubview(thumbBarImage)
        thumbBarImage.image = #imageLiteral(resourceName: "record_volume_control_ico")
        thumbBarImage.contentMode = .scaleAspectFit
        
        thumbBarImage.isUserInteractionEnabled = true
        let panGes = UIPanGestureRecognizer(target: self, action: #selector(actionPan(sender:)))
        thumbBarImage.addGestureRecognizer(panGes)
        
    }
    
    
    func actionPan(sender: UIPanGestureRecognizer) {
        let transPoint = sender.translation(in: self)
        let transX = transPoint.x
        var newCenter = CGPoint(x: (sender.view?.center.x)! + transX, y: (sender.view?.center.y)!)
        // 设置边界
        let space = 5 * spaceW
        newCenter.x = max(space, newCenter.x)
        newCenter.x = min(min(scrollViewContenW - space, boundsW - space), newCenter.x)
        sender.view?.center = newCenter
        sender.setTranslation(CGPoint.zero, in: self)
        updateCutView()
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let pointXArray = pointXArray  else {
            return
        }
        if pointXArray.count == 0 {return}
        let spaceTop: CGFloat = 2
        boundsH = self.bounds.size.height - spaceTop
        boundsW = self.bounds.size.width
        
        let maxiBarTrackImageW = CGFloat(pointXArray.count) * spaceW
        scrollViewContenW = maxiBarTrackImageW
        let path = UIBezierPath()
        for i in 0 ..< pointXArray.count {
            let x = CGFloat(i) * spaceW
            path.move(to: CGPoint(x: x, y: boundsH))
            path.addLine(to: CGPoint(x: x, y: boundsH * (1 - pointXArray[i])))
        }
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = self.waveStrokeColor.cgColor
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = kLineWidth
        playBackView.layer.addSublayer(shapeLayer)
        
        let shapeLayer1 = CAShapeLayer()
        shapeLayer1.strokeColor = self.waveHightStrokeColor.cgColor
        shapeLayer1.path = path.cgPath
        shapeLayer1.lineWidth = kLineWidth
        playHightView.layer.addSublayer(shapeLayer1)
        
        playHightView.layer.masksToBounds = true
        playBackView.frame = CGRect(x: 0, y: 0, width: scrollViewContenW, height: boundsH)
        
        
        scrollView.contentSize = CGSize(width: maxiBarTrackImageW, height: boundsH)
        var cgRect = bounds
        cgRect.origin.y = 4
        scrollView.frame = cgRect
        
        if scrollViewContenW - boundsW > 0 {
            scrollView.contentOffset = CGPoint(x: scrollViewContenW - boundsW, y: 0)
        }
        
        initThumbRect()
        updateCutView()
        
    }
    
    
    fileprivate func initThumbRect() {
        //        // 初始位置 在结束前3秒
        //        minSecond = 3
        var thumbBarX: CGFloat = 0
        if scrollViewContenW > boundsW {
            thumbBarX = boundsW - spaceW * 5 * minSecond
        } else {
            thumbBarX = scrollView.contentSize.width - spaceW * 5 * minSecond
        }
        thumbBarImage.frame = CGRect(x: thumbBarX, y: 2, width: 40, height: bounds.height)
    }
    
    fileprivate func updateCutView() {
        let point = thumbBarImage.convert(CGPoint(x: -thumbBarImage.bounds.width/2, y: 0), from: scrollView)
        thumbPointXIndex = Int(-point.x / spaceW)
        playHightView.frame = CGRect(x: 0, y: 0, width: -point.x, height: boundsH)
        let transPoint = thumbBarImage.convert(CGPoint(x: 0, y: 0), from: self)
        
        delegate?.changceTimeLabel(cutBarWaveView: self, centerX: -transPoint.x + thumbBarImage.bounds.size.width/2, thumbPointXIndex: thumbPointXIndex)
    }
}

// MARK: - open API
extension CutBarWaveView {
    /// 传入播放的进度
    func setPlayProgress(thumbPointXIndex :Int) {
        self.thumbPointXIndex = thumbPointXIndex
        playHightView.frame = CGRect(x: 0, y: 0, width: CGFloat(thumbPointXIndex * 4), height: boundsH)
    }
}

extension CutBarWaveView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCutView()
    }
}

