//
//  PlayRecordViewController.swift
//  FMDemo
//
//  Created by mba on 17/1/25.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit
import AVFoundation

class PlayRecordViewController: UIViewController {
    var url: URL?
    var pointXArray: [CGFloat]?

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bannerImg: UIImageView!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var slider: PlayBarWaveView!
    
    @IBOutlet weak var listenPlayBtn: UIButton!
    @IBOutlet weak var listenStatusLabel: UILabel!
    @IBOutlet weak var cutBtn: UIButton!
    @IBOutlet weak var savaBtn: UIButton!

    /// 保存点击图片
    var imgDictArray: [[Int:UIImage]] = [[Int:UIImage]]()
    var thumbPointXIndex: Int = 0
    var totalTime: TimeInterval {
        return Double(pointXArray?.count ?? 0) * 0.2
    }
    
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
    
    var sliderTime: TimeInterval = 0 {
        didSet{
            player?.currentTime = sliderTime
            updateTime()
        }
    }
    
    var sliderTimer: Timer?
    var tipTimer: Timer?
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
        player.player?.delegate = self
        slider.pointXArray = pointXArray
        actionPlayClick(sender: listenPlayBtn)
        totalTimeLabel.text = TimeTool.getFormatTime(timerInval: totalTime)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pausePlay()
    }
    
    func updateTime() {
//        let playTime = TimeTool.getFormatTime(timerInval:(player.currentTime))//player.currentTime  第一秒0.9几
////        let endTime = TimeTool.getFormatTime(timerInval: player.duration)
//        timeLabel.text = "\(playTime)"
//        slider.value = Float(player.currentTime / player.duration * Double(pointXArray?.count ?? 0))
        
        if thumbPointXIndex >= (pointXArray?.count ?? 0){
            stopPlay()
            thumbPointXIndex = 0
            bannerImg.image = #imageLiteral(resourceName: "record_bannerBg")
            return
        }
        
        thumbPointXIndex = thumbPointXIndex + 1
        slider.setPlayProgress(thumbPointXIndex: thumbPointXIndex)
        timeLabel.text = TimeTool.getFormatTime(timerInval:(Double(thumbPointXIndex) * 0.2))
        setSpannerImg()
    }
    
    func sliderTimerEvent() {
        updateTime()
    }

}

extension PlayRecordViewController {
    func setup() {
        listenPlayBtn.addTarget(self, action: #selector(actionPlayClick), for: .touchUpInside)
        listenPlayBtn.adjustsImageWhenHighlighted = false
        savaBtn.addTarget(self, action: #selector(actionSave), for: .touchUpInside)
        cutBtn.addTarget(self, action: #selector(actionCut), for: .touchUpInside)
        slider.slider.addTarget(self, action: #selector(actionSlider), for: .valueChanged)        
    }
}

extension PlayRecordViewController {
    //MARK: 点击播放
    func actionPlayClick(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected { // 播放状态
            listenStatusLabel.text = "暂停"
            thumbPointXIndex == 0 ? startPlay() : continuePlay()
            
        } else {
            listenStatusLabel.text = "播放"
            pausePlay()
        }
    }
    
    func actionSave() {

    }
    
    
    func actionCut(sender: UIButton) {
//        pausePlay()
    }
    
    func actionSlider(sender: UISlider) {
        pausePlay()
        thumbPointXIndex = Int(sender.value)
//        let progress = Double(sender.value) / Double(pointXArray?.count ?? 0)
//        player.currentTime = TimeInterval(progress * player.duration)
        sliderTime = Double(thumbPointXIndex) * 0.2
        if listenPlayBtn.isSelected {// 在播放中
            continuePlay()
        } else {
            
        }
        
    }
}

extension PlayRecordViewController {
    func initTimer() {
//        tipTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(tipTimerEvent), userInfo: nil, repeats: true)
        sliderTimer = Timer.scheduledTimer(timeInterval: kWaveTime, target: self, selector: #selector(sliderTimerEvent), userInfo: nil, repeats: true)
    }
    
    func pauseTimer() {
        tipTimer?.fireDate = Date.distantFuture
        sliderTimer?.fireDate = Date.distantFuture
    }
    
    func continueTimer() {
        tipTimer?.fireDate = Date()
        sliderTimer?.fireDate = Date()
    }
    
    func stopTimer() {
        sliderTimer?.invalidate()
        sliderTimer = nil
        tipTimer?.invalidate()
        tipTimer = nil
    }
}

extension PlayRecordViewController {
    
    func startPlay() {
        sliderTime = kWaveTime
        player?.startPlay()
        initTimer()
    }
    
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


extension PlayRecordViewController: AVAudioPlayerDelegate{
    
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        if flag {
//            print("finishS")
//            stopPlay()
//        } else {
//            print("finishError")
//        }
//    }
}
