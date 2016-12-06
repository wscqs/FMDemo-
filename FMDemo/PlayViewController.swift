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

    var slider = UISlider(frame: CGRect(x: 10, y: 50, width: UIScreen.main.bounds.width - 20, height: 20))
    var label = UILabel(frame: CGRect(x: 10, y: 80, width: UIScreen.main.bounds.width - 20, height: 20))
    var btn = UIButton(frame: CGRect(x: 10, y: 110, width: UIScreen.main.bounds.width - 20, height: 20))
    
    var player: AVAudioPlayer!
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(slider)
        view.addSubview(label)
        view.addSubview(btn)
        
        btn.setTitle("播放", for: .normal)
        btn.setTitle("暂停", for: .selected)
        btn.addTarget(self, action: #selector(actionClick), for: .touchUpInside)
        btn.backgroundColor = UIColor.gray
        
        let url = Bundle.main.url(forResource: "yijianji", withExtension: "caf")
        player = try? AVAudioPlayer(contentsOf: url!)
        player.delegate = self
        
        slider.minimumValue = 0
        slider.maximumValue = Float(player.duration)
        slider.value = 0
        slider.isContinuous = false
        slider.addTarget(self, action: #selector(actionSlider), for: .valueChanged)
        
        let startTime = TimeTool.getFormatTime(timerInval: 0)
        let endTime = TimeTool.getFormatTime(timerInval: player.duration)
        label.text = "\(startTime)\\\(endTime)"
    }
    
    func actionSlider(sender: UISlider) {
        player.currentTime = TimeInterval(sender.value)
        updateLabel(currentTime: player.currentTime)
    }
    
    func actionClick(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            player.play()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerUP), userInfo: nil, repeats: true)
        } else {
            player.pause()
            timer.fireDate = Date.distantFuture
        }
    }
    
    func timerUP() {
        slider.value = Float(player.currentTime)
        updateLabel(currentTime: player.currentTime)
    }
    
    func updateLabel(currentTime: TimeInterval) {
        let startTime = TimeTool.getFormatTime(timerInval: currentTime)
        let endTime = TimeTool.getFormatTime(timerInval: player.duration)
        label.text = "\(startTime)\\\(endTime)"
    }
    
}

extension PlayViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("finishS")
            btn.isSelected = false
        } else {
            print("finishError")
        }
    }
}
