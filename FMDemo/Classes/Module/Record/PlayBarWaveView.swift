//
//  BarWaveView.swift
//  FMDemo
//
//  Created by mba on 17/1/19.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit
protocol PlayBarWaveViewDelegate: NSObjectProtocol{
    func changceTimeLabel(cutBarWaveView: PlayBarWaveView, thumbPointXIndex: Int)
}

class PlayBarWaveView: UIView {

    weak var delegate: PlayBarWaveViewDelegate?
    
    var pointXArray: Array<CGFloat>? {
        didSet{
            guard pointXArray != nil else {
                return
            }
//            setNeedsDisplay()
        }
    }

    fileprivate var thumbBarImage: UIImageView = UIImageView()
    fileprivate var playHightView: UIView = UIView()
    fileprivate var playBackView: UIView = UIView()
    fileprivate var thumbPointXIndex: Int = 0
    
    var kLineWidth: CGFloat = 2.0
    var spaceW: CGFloat = 2.0 * 2
    
    var boundsH: CGFloat = 0
    var boundsW: CGFloat = 0
    var scrollViewContenW: CGFloat = 0
    
    var viewspaceTop: CGFloat = 4
    var viewspaceLeft: CGFloat = 2
    
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

        addSubview(playBackView)
        addSubview(playHightView)

        addSubview(thumbBarImage)
        thumbBarImage.image = #imageLiteral(resourceName: "record_volume_control_ico")
        thumbBarImage.contentMode = .scaleAspectFit
        
        thumbBarImage.isUserInteractionEnabled = true
        let panGes = UIPanGestureRecognizer(target: self, action: #selector(actionPan(sender:)))
        thumbBarImage.addGestureRecognizer(panGes)
        thumbBarImage.frame = CGRect(x: 0, y: 2, width: 60, height: bounds.height)
    }
    
    var isDraging: Bool? = false
    func actionPan(sender: UIPanGestureRecognizer) {
        if sender.state == .ended {
            isDraging = false
        } else {
            isDraging = true
        }
        let transPoint = sender.translation(in: self)
        let transX = transPoint.x
        
        var newCenter = CGPoint(x: (sender.view?.center.x)! + transX, y: (sender.view?.center.y)!)
        // 设置边界
        let space:CGFloat = viewspaceLeft
        newCenter.x = max(space, newCenter.x)
        newCenter.x = min(min(scrollViewContenW + viewspaceLeft, boundsW + viewspaceLeft), newCenter.x)
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
        boundsW = self.bounds.size.width - viewspaceLeft * 2
        
        
        var widthScaling: CGFloat = 1
        var space: CGFloat = 2
        if CGFloat(pointXArray.count * 4) > boundsW {
            widthScaling = boundsW / CGFloat(pointXArray.count * 4)
            scrollViewContenW = boundsW
            //大于10分钟无间距
            if pointXArray.count > 3000 {
                space = 1
                widthScaling = boundsW / CGFloat(pointXArray.count * 2)
            }
        }else {
            scrollViewContenW = CGFloat(pointXArray.count * 4)
        }
        kLineWidth = kLineWidth * widthScaling
        spaceW = kLineWidth * space
        
        let path = UIBezierPath()
        for i in 0 ..< pointXArray.count {
            let x = viewspaceLeft + CGFloat(i) * spaceW
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
        playBackView.frame = CGRect(x: viewspaceLeft, y: viewspaceTop, width: boundsW, height: boundsH)

//        updateCutView()
        
    }
    
    
    
    fileprivate func updateCutView() {
        let point = thumbBarImage.convert(CGPoint(x: -thumbBarImage.bounds.width/2, y: 0), from: self)
        thumbPointXIndex = Int(-point.x / spaceW)
        playHightView.frame = CGRect(x: viewspaceLeft, y: viewspaceTop, width: -point.x, height: boundsH)
        
        delegate?.changceTimeLabel(cutBarWaveView: self, thumbPointXIndex: thumbPointXIndex)
    }
    
    /// 父控件拦截了手势，所以特殊处理
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var view = super.hitTest(point, with: event)
        if view == nil {
            let newPoint = self.thumbBarImage.convert(point, from: self)
            if self.thumbBarImage.bounds.contains(newPoint) {
                view = self.thumbBarImage
            }
        }
        return view
    }
}

// MARK: - open API
extension PlayBarWaveView {
    /// 传入播放的进度
    func setPlayProgress(thumbPointXIndex :Int) {
        if isDraging!{
            return
        }
        self.thumbPointXIndex = thumbPointXIndex
        playHightView.frame = CGRect(x: viewspaceLeft, y: viewspaceTop, width: CGFloat(thumbPointXIndex) * spaceW, height: boundsH)
        thumbBarImage.frame = CGRect(x: playHightView.frame.maxX - 30 - 1, y: 2, width: 60, height: bounds.height)
    }
}

