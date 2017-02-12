//
//  CutRecordViewController.swift
//  FMDemo
//
//  Created by mba on 17/2/6.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit
import AVFoundation

class CutRecordViewController: UIViewController {
    
    var url: URL?
    var pointArray: [CGFloat]?
    
    @IBOutlet weak var slider: BarWaveView!
    @IBOutlet weak var listenPlayBtn: UIButton!
    @IBOutlet weak var cutBtn: UIButton!
    @IBOutlet weak var savaBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
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
        
        slider.pointArray = pointArray
        
        
        initStatus()
        actionPlayClick(sender: listenPlayBtn)
        
    }
    
    func initStatus() {
        //        slider.slider.minimumValue = 0
        //        slider.slider.maximumValue = Float(player.duration)
        //        slider.slider.value = 0
    }
    
    func updateTime() {
        let playTime = TimeTool.getFormatTime(timerInval:(player.currentTime))//player.currentTime  第一秒0.9几
        let endTime = TimeTool.getFormatTime(timerInval: player.duration)
        timeLabel.text = "\(playTime)\\\(endTime)"
        slider.slider.setValue(Float(player.currentTime / player.duration * Double(pointArray?.count ?? 0)), animated: true)
    }
    
    func sliderTimerEvent() {
        //        let sliderTime = player.currentTime
        updateTime()
        if player.currentTime >= player.duration {
            stopPlay()
        }
    }
    
}

extension CutRecordViewController {
    func setup() {
        listenPlayBtn.addTarget(self, action: #selector(actionPlayClick), for: .touchUpInside)
        savaBtn.addTarget(self, action: #selector(actionSave), for: .touchUpInside)
        cutBtn.addTarget(self, action: #selector(actionCut), for: .touchUpInside)
        slider.slider.addTarget(self, action: #selector(actionSlider), for: .valueChanged)
        
        slider.slider.isContinuous = false // 滑动结束 才会执行valueChanged 事件
    }
}

extension CutRecordViewController {
    //MARK: 点击播放
    func actionPlayClick(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected { // 播放状态
            
            player.currentTime == 0 ? startPlay() : continuePlay()
            
        } else {
            pausePlay()
        }
    }
    
    func actionSave() {
        //        let url = isCuted ? mergeExportURL : MBAAudio.url
        //        MBAAudioUtil.changceToMp3(of: url, mp3Name: "我")
        
        let alertController = UIAlertController(title: nil, message: "给课程起个名字吧", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let okAction = UIAlertAction(title: "确定", style: .default) { (action) in
            //            print(alertController.textFields?.first?.text)
        }
        alertController.addAction(okAction)
        alertController.addTextField { (textFiled) in
            textFiled.clearButtonMode = .whileEditing
        }
        present(alertController, animated: true, completion: nil)
    }
    
    
    func actionCut(sender: UIButton) {
        pausePlay()
        
    }
    
    func actionSlider(sender: UISlider) {
        pausePlay()
        let progress = Double(sender.value) / Double(pointArray?.count ?? 0)
        player.currentTime = TimeInterval(progress * player.duration)
        sliderTime = player.currentTime
        if listenPlayBtn.isSelected {// 在播放中
            continuePlay()
        } else {
            
        }
        
    }
}

extension CutRecordViewController {
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

extension CutRecordViewController {
    
    //    func initPlay() {
    //        sliderTime = 0
    //    }
    
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
    }
}


extension CutRecordViewController: AVAudioPlayerDelegate{
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("finishS")
            //            tipTimer?.fireDate = Date.distantFuture
            stopPlay()
        } else {
            print("finishError")
        }
    }
}
