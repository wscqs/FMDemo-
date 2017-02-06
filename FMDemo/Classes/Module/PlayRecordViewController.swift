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
//        {
//        didSet{
//            guard let url = url else {
//                return
//            }
//            
//            let url1 = Bundle.main.url(forResource: "luyingshort.caf", withExtension: nil)
//            player = MBAAudioPlayer(contentsOf: url)
//            player.player?.delegate = self
//            slider.url = url1!
//            
//            initStatus()
//            actionPlayClick(sender: listenPlayBtn)
//        }
//    }
    
    @IBOutlet weak var slider: WaveformView!
    @IBOutlet weak var listenPlayBtn: UIButton!
    @IBOutlet weak var cutBtn: UIButton!
    @IBOutlet weak var savaBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    var sliderTime: TimeInterval = 0
    var sliderTimer: Timer?
    var tipTimer: Timer?
    var player: MBAAudioPlayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        url = Bundle.main.url(forResource: "luyingshort.caf", withExtension: nil)
        guard let url = url else {
            return
        }
        player = MBAAudioPlayer(contentsOf: url)
        player.player?.delegate = self
        slider.url = url
        
        initStatus()
        actionPlayClick(sender: listenPlayBtn)
                
    }
    
    func initStatus() {
        slider.minimumValue = 0
        slider.maximumValue = Float(player.duration)
        slider.value = 0
    }
    
    func updateLabel() {
        let playTime = TimeTool.getFormatTime(timerInval:(player.currentTime + 0.2))//player.currentTime  第一秒0.9几
        let endTime = TimeTool.getFormatTime(timerInval: player.duration)
        timeLabel.text = "\(playTime)\\\(endTime)"
    }
    
    func sliderTimerEvent() {
        sliderTime = sliderTime + 0.01
        slider.value = Float(sliderTime)
        if sliderTime >= player.duration {
            stopPlay()
        }
    }
    
    func tipTimerEvent() {
        updateLabel()
    }
}

extension PlayRecordViewController {
    func setup() {
        listenPlayBtn.addTarget(self, action: #selector(actionPlayClick), for: .touchUpInside)
        
        savaBtn.addTarget(self, action: #selector(actionSave), for: .touchUpInside)
        cutBtn.addTarget(self, action: #selector(actionCut), for: .touchUpInside)
        
        slider.addTarget(self, action: #selector(actionSlider), for: .valueChanged)
        
        slider.isContinuous = false // 滑动结束 才会执行valueChanged 事件
    }
}

extension PlayRecordViewController {
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
        player.currentTime = TimeInterval(sender.value)
        sliderTime = player.currentTime
        updateLabel()
        if listenPlayBtn.isSelected {// 在播放中
            continuePlay()
        } else {
            
        }
        
    }
}

extension PlayRecordViewController {
    func initTimer() {
        tipTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(tipTimerEvent), userInfo: nil, repeats: true)
        sliderTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(sliderTimerEvent), userInfo: nil, repeats: true)
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
        sliderTime = 0
        player?.currentTime = 0
        updateLabel()
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


extension PlayRecordViewController: AVAudioPlayerDelegate{
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("finishS")
            tipTimer?.fireDate = Date.distantFuture
        } else {
            print("finishError")
        }
    }
}
