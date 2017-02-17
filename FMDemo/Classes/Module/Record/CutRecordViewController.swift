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
    var pointArray: [CGFloat]? = [0.696240305900574, 0.696240305900574, 0.696240305900574, 0.696240305900574, 0.696240305900574, 0.44433605670929, 0.249422714114189, 0.149287849664688, 0.120376735925674, 0.120376735925674, 0.120376735925674, 0.205947756767273, 0.261922419071198, 0.261922419071198, 0.261922419071198, 0.261922419071198, 0.261922419071198, 0.147027000784874, 0.0880005806684494, 0.0493980683386326, 0.029566403478384, 0.00566995795816183, 0.0097912959754467, 0.0097912959754467, 0.0116009945049882, 0.0250983666628599, 0.0250983666628599, 0.135464236140251, 0.135464236140251, 0.135464236140251, 0.135464236140251, 0.135464236140251, 0.081079863011837, 0.0455132201313972, 0.0322628356516361, 0.0322628356516361, 0.064118854701519, 0.064118854701519, 0.064118854701519, 0.064118854701519, 0.06013423204422, 0.0668420121073723, 0.0668420121073723, 0.0668420121073723, 0.0668420121073723, 0.055138848721981, 0.030951539054513, 0.0340068563818932, 0.039409264922142, 0.039409264922142, 0.039409264922142, 0.039409264922142, 0.039409264922142, 0.0235877744853497, 0.0132407136261463, 0.0128546329215169, 0.0128546329215169, 0.0128546329215169, 0.0128546329215169, 0.0106039550155401, 0.00939829740673304, 0.0107546709477901, 0.0107546709477901, 0.0121961031109095, 0.0130802737548947, 0.0130802737548947, 0.0130802737548947, 0.0130802737548947, 0.0130802737548947, 0.00900998059660196, 0.00900998059660196, 0.0149638624861836, 0.02615518681705, 0.0372387617826462, 0.0372387617826462, 0.0464773364365101, 0.0464773364365101, 0.0464773364365101, 0.0464773364365101, 0.0464773364365101, 0.0359571613371372, 0.021521570160985, 0.0120808742940426, 0.016248544678092, 0.016248544678092, 0.016248544678092, 0.016248544678092, 0.0142917903140187, 0.00802252721041441, 0.00884392485022545, 0.0107653513550758, 0.0107653513550758, 0.0107653513550758, 0.0107653513550758, 0.0100963488221169, 0.010274974629283, 0.0105596892535686, 0.0105596892535686, 0.0105596892535686, 0.0105596892535686, 0.0111185926944017, 0.0111185926944017, 0.0111185926944017, 0.0111185926944017, 0.0111185926944017, 0.00881586782634258, 0.00922708492726088, 0.00922708492726088, 0.111367024481297, 0.111367024481297, 0.111367024481297, 0.111367024481297, 0.111367024481297, 0.0710737109184265, 0.0398963838815689, 0.0238793194293976, 0.0134043730795383, 0.00802296306937933, 0.00841098092496395, 0.00853606034070253, 0.00933864712715149, 0.0247261859476566, 0.0247261859476566]
    
    @IBOutlet weak var slider: CutBarWaveView!
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
//        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let url = url else {
            return
        }
        player = MBAAudioPlayer(contentsOf: url)
        player.player?.delegate = self
        
        slider.pointXArray = pointArray
        
        
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
//        slider.slider.setValue(Float(player.currentTime / player.duration * Double(pointArray?.count ?? 0)), animated: true)
//        slider.setPlayProgress(thumbPointXIndex: <#T##Int#>)
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
