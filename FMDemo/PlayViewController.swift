//
//  PlayViewController.swift
//  FMDemo
//
//  Created by mba on 16/12/6.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import UIKit
import AVFoundation

class PlayViewController: UIViewController {

    var strokeSlider = UISlider(frame: CGRect(x: 10, y: 50, width: UIScreen.main.bounds.width - 20, height: 20))
    var strokBtn = UIButton(frame: CGRect(x: 10, y: 190, width: UIScreen.main.bounds.width - 20, height: 20))
    
    var cancelBtn = UIButton(frame: CGRect(x: 10, y: 220, width: UIScreen.main.bounds.width - 20, height: 20))
    var yesBtn = UIButton(frame: CGRect(x: 10, y: 250, width: UIScreen.main.bounds.width - 20, height: 20))

    var slider = UISlider(frame: CGRect(x: 10, y: 100, width: UIScreen.main.bounds.width - 20, height: 20))
    var label = UILabel(frame: CGRect(x: 10, y: 130, width: UIScreen.main.bounds.width - 20, height: 20))
    var btn = UIButton(frame: CGRect(x: 10, y: 160, width: UIScreen.main.bounds.width - 20, height: 20))
    
    var player: AVAudioPlayer!
    var url:URL?
    var exportURL: URL!    

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        
        view.backgroundColor = UIColor.gray

        view.addSubview(slider)
        view.addSubview(label)
        view.addSubview(btn)
        
        view.addSubview(strokBtn)
        view.addSubview(strokeSlider)
        view.addSubview(cancelBtn)
        view.addSubview(yesBtn)
        
        strokBtn.setTitle("裁剪", for: .normal)
        strokBtn.setTitle("裁剪中", for: .selected)
        strokBtn.addTarget(self, action: #selector(actionStroke), for: .touchUpInside)
        cancelBtn.setTitle("取消", for: .normal)
        yesBtn.setTitle("确定", for: .normal)
        cancelBtn.addTarget(self, action: #selector(actionStrokeCancel), for: .touchUpInside)
        yesBtn.addTarget(self, action: #selector(actionStrokeYes), for: .touchUpInside)
        strokeSlider.addTarget(self, action: #selector(actionStrokeSlider), for: .valueChanged)
        strokeHide(isHidden: true)

        
        btn.setTitle("播放", for: .normal)
        btn.setTitle("暂停", for: .selected)
        btn.addTarget(self, action: #selector(actionClick), for: .touchUpInside)
        
        slider.addTarget(self, action: #selector(actionSlider), for: .valueChanged)


        let url = Bundle.main.url(forResource: "yijianji", withExtension: "caf")
        loadPlay(url: url)
    }
    
    func loadPlay(url: URL?) {
        self.url = url
        player = try? AVAudioPlayer(contentsOf: url!)
        player.delegate = self
        player.prepareToPlay()
        
        slider.minimumValue = 0
        slider.maximumValue = Float(player.duration)
        slider.value = 0
        strokeSlider.minimumValue = 0
        strokeSlider.maximumValue = Float(player.duration)
        strokeSlider.value = 0
        strokeSlider.isContinuous = false
        updateLabel()
    }
    func actionStrokeCancel() {
        strokBtn.isSelected = false
        strokeHide(isHidden: true)
    }
    
    func actionStrokeYes() {
        strokBtn.isSelected = false
        strokeHide(isHidden: true)
        
        strokeTest()
    }
    
    func actionSlider(sender: UISlider) {
        pausePlay()
        player.currentTime = TimeInterval(sender.value)
        sliderTime = player.currentTime
        updateLabel()
        if btn.isSelected {// 在播放中
            continuePlay()
        } else {
            
        }
        
    }
    
    func actionStroke(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected { // 裁剪中
            strokeHide(isHidden: false)
        } else {
            strokeHide(isHidden: true)
        }
    }
    
    func strokeHide(isHidden: Bool) {
        strokeSlider.isHidden = isHidden
        yesBtn.isHidden = isHidden
        cancelBtn.isHidden = isHidden
    }
    
    func actionStrokeSlider(sender: UISlider) {
        slider.value = sender.value
        actionSlider(sender: sender)
    }
    
    //MARK: 点击播放
    func actionClick(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected { // 播放状态
            
            if strokBtn.isSelected { // 裁剪中
                if player.currentTime == 0 {
                    actionStrokeSlider(sender: strokeSlider)
                }else{
                    continuePlay()
                }
            }else {
                player.currentTime == 0 ? startPlay() : continuePlay()
            }
            
        } else {
            pausePlay()
        }
    }
    
    func tipTimerEvent() {
        updateLabel()
    }
    
    func sliderTimerEvent() {
        sliderTime = sliderTime + 0.01
        slider.value = Float(sliderTime)
        if sliderTime >= player.duration {
            stopPlay()
        }
    }
    
    
    func updateLabel() {
        print((player.currentTime + 0.99) ,player.duration)
        let playTime = TimeTool.getFormatTime(timerInval:(player.currentTime + 0.99))//player.currentTime  第一秒0.9几
        let endTime = TimeTool.getFormatTime(timerInval: player.duration)
        label.text = "\(playTime)\\\(endTime)"
    }
    
    
    func startPlay() {
        playTime = 0
        sliderTime = 0
        player.currentTime = playTime
        updateLabel()
        player.play()
        tipTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(tipTimerEvent), userInfo: nil, repeats: true)
        sliderTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(sliderTimerEvent), userInfo: nil, repeats: true)
    }
    
    
    func pausePlay() {
        player.pause()
        pauseTimer()
    }
    
    func continuePlay() {
        player.play()
        continueTimer()
    }
    
    func stopPlay() {
        sliderTimer.fireDate = Date.distantFuture
        btn.isSelected = false
    }
    
    
    func pauseTimer() {
        tipTimer.fireDate = Date.distantFuture
        sliderTimer.fireDate = Date.distantFuture
    }
    
    func continueTimer() {
        tipTimer.fireDate = Date()
        sliderTimer.fireDate = Date()
    }
    
    func stopTimer() {
        sliderTimer.invalidate()
        sliderTimer = nil
        tipTimer.invalidate()
        tipTimer = nil
    }
    
    var playTime: TimeInterval!
    var sliderTime: TimeInterval!
    var sliderTimer: Timer!
    var tipTimer: Timer!
    
}
extension PlayViewController {
    func strokeTest() {
        // 1.拿到预处理音频文件
        let songAsset = AVURLAsset(url: url!)

        let exportPath = (Date().formatDate + ".caf").docDir()
        exportURL = URL(fileURLWithPath: exportPath)
        print(exportURL)
        
        // 2.创建新的音频文件
        if FileManager.default.fileExists(atPath: exportPath) {
            try? FileManager.default.removeItem(atPath: exportPath)
        }
        
        // 3.创建音频输出会话
        let exportSession = AVAssetExportSession(asset: songAsset, presetName: AVAssetExportPresetPassthrough)
        
        let startStrokeTime = strokeSlider.value
        let stopStrokeTime = player.duration
        let startTime = CMTime(seconds: Double(startStrokeTime), preferredTimescale: 1000)
        let stopTime = CMTime(seconds: stopStrokeTime, preferredTimescale: 1000)
        let exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
        // 4.设置音频输出会话并执行
        exportSession?.outputURL = exportURL
        exportSession?.outputFileType = AVFileTypeCoreAudioFormat
        exportSession?.timeRange = exportTimeRange
        exportSession?.exportAsynchronously {
            if AVAssetExportSessionStatus.completed == exportSession?.status {
                print("AVAssetExportSessionStatusCompleted")
                
                DispatchQueue.main.async {
                    self.loadPlay(url: self.exportURL)
                }
            } else if AVAssetExportSessionStatus.failed == exportSession?.status {
                print("AVAssetExportSessionStatusFailed")
            } else {
                print("Export Session Status: %d", exportSession?.status ?? "")
            }
        }
        
    }
}


extension PlayViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("finishS")
            tipTimer.fireDate = Date.distantFuture
        } else {
            print("finishError")
        }
    }
}
