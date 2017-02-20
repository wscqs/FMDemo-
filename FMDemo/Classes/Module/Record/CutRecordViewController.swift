//
//  CutRecordViewController.swift
//  FMDemo
//
//  Created by mba on 17/1/25.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit
import AVFoundation

class CutRecordViewController: UIViewController {
    var url: URL?
    var pointXArray: [CGFloat]?{
        didSet {
            totalTime = Double(pointXArray?.count ?? 0) * 0.2
        }
    }
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bannerImg: UIImageView!
    @IBOutlet weak var sliderTimeLabel: UILabel!
    @IBOutlet weak var slider: CutBarWaveView!
    @IBOutlet weak var listenShowTimeLabel: UILabel!
    
    @IBOutlet weak var listenPlayBtn: UIButton!
    @IBOutlet weak var listenStatusLabel: UILabel!
    @IBOutlet weak var cutBtn: UIButton!
//    @IBOutlet weak var savaBtn: UIButton!
    
    /// 保存点击图片
    var imgDictArray: [[Int:UIImage]] = [[Int:UIImage]]()
    var thumbPointXIndex: Int = 0 {
        didSet {
            playTime = Double(thumbPointXIndex) * 0.2
//            player.currentTime = playTime
        }
    }
    var totalTime: TimeInterval = 0
    var playTime: TimeInterval = 0
    var cutTime: TimeInterval = 0
    
    func setSpannerImg() {
        for imgDict in imgDictArray {
            guard let image = imgDict[thumbPointXIndex] else { continue }
            bannerImg.image = image
            let transition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            transition.type = kCATransitionFade
            bannerImg.layer.add(transition, forKey: nil)
            break
        }
    }
    
//    var sliderTime: TimeInterval = 0 {
//        didSet{
//            player?.currentTime = sliderTime
//            updateTime()
//        }
//    }
    
    /// 播放的计时器
    var sliderTimer: Timer?
//    var tipTimer: Timer?
    var player: MBAAudioPlayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let url = url else {
            return
        }
        player = MBAAudioPlayer(contentsOf: url)
        slider.pointXArray = pointXArray
        slider.delegate = self
        timeLabel.text = "00:00-\(TimeTool.getFormatTime(timerInval: totalTime))"
        initTimer()
        pauseTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pausePlay()
    }
    
    func updateTime() {        
        if thumbPointXIndex >= (pointXArray?.count ?? 0){
            stopPlay()
            thumbPointXIndex = Int(self.cutTime / 0.2)
            bannerImg.image = #imageLiteral(resourceName: "record_bannerBg")
            listenShowTimeLabel.isHidden = true
            return
        }
        
        thumbPointXIndex = thumbPointXIndex + 1
        slider.setPlayProgress(thumbPointXIndex: thumbPointXIndex)
        listenShowTimeLabel.text = "\(playTime.getFormatTime())-\(totalTime.getFormatTime())"
        setSpannerImg()
    }
    
    func sliderTimerEvent() {
        updateTime()
    }
    
}

extension CutRecordViewController {
    func setup() {
        listenPlayBtn.addTarget(self, action: #selector(actionPlayClick), for: .touchUpInside)
        listenPlayBtn.adjustsImageWhenHighlighted = false
        cutBtn.addTarget(self, action: #selector(actionCut), for: .touchUpInside)
    }
}

extension CutRecordViewController {
    //MARK: 点击播放
    func actionPlayClick(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected { // 播放状态
            listenStatusLabel.text = "暂停"
            listenShowTimeLabel.isHidden = false
            
            player.currentTime = playTime
            continuePlay()
            
        } else {
            listenShowTimeLabel.isHidden = true
            listenStatusLabel.text = "播放"
            pausePlay()
        }
    }
    
    
    func actionCut(sender: UIButton) {
        //        pausePlay()
    }
    
}

extension CutRecordViewController {
    func initTimer() {
        //        tipTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(tipTimerEvent), userInfo: nil, repeats: true)
        sliderTimer = Timer.scheduledTimer(timeInterval: kWaveTime, target: self, selector: #selector(sliderTimerEvent), userInfo: nil, repeats: true)
    }
    
    func pauseTimer() {
//        tipTimer?.fireDate = Date.distantFuture
        sliderTimer?.fireDate = Date.distantFuture
    }
    
    func continueTimer() {
//        tipTimer?.fireDate = Date()
        sliderTimer?.fireDate = Date()
    }
    
    func stopTimer() {
        sliderTimer?.invalidate()
        sliderTimer = nil
//        tipTimer?.invalidate()
//        tipTimer = nil
    }
}

extension CutRecordViewController {
    
    func pausePlay() {
        player?.pausePlay()
        pauseTimer()
    }
    
    func continuePlay() {
        player?.continuePlay()
        continueTimer()
    }
    
    func stopPlay() {
        pauseTimer()
        listenPlayBtn.isSelected = false
        listenStatusLabel.text = "播放"
    }
}

extension CutRecordViewController: CutBarWaveViewDelegate {
    func changceTimeLabel(cutBarWaveView: CutBarWaveView, centerX: CGFloat, thumbPointXIndex: Int) {
        
        let sliderTime = Double(thumbPointXIndex) * 0.2
        sliderTimeLabel.text = sliderTime.getFormatTime()
        sliderTimeLabel.sizeToFit()
        sliderTimeLabel.textAlignment = .center
        sliderTimeLabel.center = CGPoint(x: centerX, y: 12)

        self.thumbPointXIndex = thumbPointXIndex
        self.cutTime = Double(thumbPointXIndex) * 0.2
        player.currentTime = playTime
        timeLabel.text = "\(cutTime.getFormatTime())-\(totalTime.getFormatTime())"
        setSpannerImg()
    }
}

extension CutRecordViewController: AVAudioPlayerDelegate{
    
    //    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    //        if flag {
    //            print("finishS")
    //            stopPlay()
    //        } else {
    //            print("finishError")
    //        }
    //    }
}
