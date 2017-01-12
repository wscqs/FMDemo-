//
//  ViewController.swift
//  FMDemo
//
//  Created by mba on 16/11/30.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var listenPlayBtn: UIButton!
    @IBOutlet weak var cutBtn: UIButton!
    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var reRecordBtn: UIButton!
    @IBOutlet weak var savaBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var cutSlider: UISlider!
    @IBOutlet weak var cutCancelBtn: UIButton!
    @IBOutlet weak var cutYesBtn: UIButton!
    
    /// 配音的容器
    @IBOutlet weak var dubView: UIView!
    
    var addDubBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("添加配音", for: .normal)
        btn.setTitleColor(UIColor.lightGray, for: .normal)
        btn.sizeToFit()
        btn.addTarget(self, action: "actionAddDub", for: .touchUpInside)
        return btn
    }()
    
    
    
    var isCuted: Bool = false
    
    var timer: Timer?
    var time:TimeInterval = 0
    
    
    var playTimer: Timer?
    var playTime:TimeInterval = 0
    
    
//    var playTime: TimeInterval!
    var sliderTime: TimeInterval = 0
    var sliderTimer: Timer?
    var tipTimer: Timer?
    var player: MBAAudioPlayer!
    

    var cutExportURL: URL?
    var mergeExportURL: URL?
    
    func trans() {
//        MBAAudioUtil.changceToMp3(of: <#T##URL#>, mp3Name: <#T##String#>)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.addSubview(addBtn)
//        addBtn.setTitle("合并", for: .normal)
//        addBtn.setTitleColor(UIColor.blue, for: .normal)
//        addBtn.center = view.center
//        addBtn.sizeToFit()
//        addBtn.addTarget(self, action: "trans", for: .touchUpInside)
        
        
        
        
        recordBtn.addTarget(self, action: #selector(actionRecordClick), for: .touchUpInside)
        
        
        listenPlayBtn.addTarget(self, action: #selector(actionPlayClick), for: .touchUpInside)

        
        savaBtn.addTarget(self, action: #selector(actionSave), for: .touchUpInside)
        cutBtn.addTarget(self, action: #selector(actionCut), for: .touchUpInside)
        
        reRecordBtn.addTarget(self, action: #selector(actionReRecord), for: .touchUpInside)
        
        slider.addTarget(self, action: #selector(actionSlider), for: .valueChanged)

        slider.isContinuous = false // 滑动结束 才会执行valueChanged 事件
        

        cutSlider.isContinuous = false
        cutSlider.addTarget(self, action: #selector(actionCutSlider), for: .valueChanged)
        
        cutCancelBtn.addTarget(self, action: #selector(actionStrokeCancel), for: .touchUpInside)
        cutYesBtn.addTarget(self, action: #selector(actionStrokeYes), for: .touchUpInside)
        
        dubView.addSubview(addDubBtn)
        

        initStates()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addDubBtn.frame = dubView.bounds
    }
    
    deinit {
        
    }
    
    func initStates() {
        initStatusHide(isHidden: true)
        recordBtn.isSelected = false
        recordBtn.setTitle("开始录音", for: .normal)
        recordBtn.setTitle("录音中", for: .selected)
        cutSlider.value = 0
        initOraginTimeStatue(time:0)
        isCuted = false
        
        
        
    }
    
    
    func actionAddDub() {
//        navigationController?.pushViewController(<#T##viewController: UIViewController##UIViewController#>, animated: <#T##Bool#>)
        let dubPlayView = DubPlayView()
        dubView.addSubview(dubPlayView)
        dubPlayView.frame = dubView.bounds
    }
    
    func actionSave() {
//        let url = isCuted ? mergeExportURL : MBAAudio.url
//        MBAAudioUtil.changceToMp3(of: url, mp3Name: "我")
    }
    
    /// 初始或重置后的状态
    func actionReset() {
        
        stopRecord()
        stopPlay()
        player = nil
        MBAAudio.audioRecorder = nil
        stopTimer()
        initStates()
        
        MBACache.clearCache()
    }

    
    func actionStrokeCancel() {
        cutHide(isHidden: true)
    }
    
    func actionStrokeYes() {
        cutHide(isHidden: true)
        cutEvent()
    }
    
    /// 截取的隐藏
    func cutHide(isHidden: Bool) {
        cutCancelBtn.isHidden = isHidden
        cutYesBtn.isHidden = isHidden
        cutSlider.isHidden = isHidden
        cutBtn.isSelected = !isHidden
    }
    
    /// 录音的隐藏
    func recoredHide(isHidden: Bool) {
        listenPlayBtn.isHidden = isHidden
        cutBtn.isHidden = isHidden
        slider.isHidden = isHidden
        cutHide(isHidden: true)
        noRecordHide(isHidden: isHidden)
    }
    
    func initStatusHide(isHidden: Bool) {
        recoredHide(isHidden: true)
        cutHide(isHidden: true)
        recoredHide(isHidden: true)
        noRecordHide(isHidden: true)
    }
    
    /// 未录音时隐藏
    func noRecordHide(isHidden: Bool) {
        reRecordBtn.isHidden = isHidden
        savaBtn.isHidden = isHidden
    }
    

    func actionRecordClick(sender: UIButton) {
        if !canRecord() {
            let alertController = UIAlertController(title: "请求授权", message: "app需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克风", preferredStyle: .alert )
            let alertAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            MBAAudio.audioRecorder == nil ? startRecord() : continueRecord()
        }else{
            pauseRecord()
        }
    }
    
    
    //开始录音
    func startRecord() {
        recoredHide(isHidden: true)
        
        MBAAudio.initRecord()
        MBAAudio.startRecord()
        timerInit()
        // 代理设为本身
        MBAAudio.audioRecorder?.delegate = self
        recordBtn.setTitle("暂停", for: .normal)
        
        recoredHide(isHidden: true)
    }
    

    //暂停录音
    func pauseRecord() {
        recoredHide(isHidden: false)
        
        MBAAudio.pauseRecord()
        timerPause()
        
        if isCuted { // 如果裁剪过，就合并

            guard let mergeExportURL = mergeExportURL,
                let recodedVoiceURL = MBAAudio.url
                 else {
                    print("mergeExportURL error")
                    return
            }
            MBAAudioUtil.mergeAudio(url1: mergeExportURL, url2: recodedVoiceURL, handleComplet: { (mergeExportURL) in
                if let mergeExportURL = mergeExportURL {
                    self.mergeExportURL = mergeExportURL
                    self.loadPlay(url: mergeExportURL)
                }
            })
            
        } else {
            loadPlay(url: MBAAudio.url)
        }
        
    }
    
    //继续录音
    func continueRecord() {
        recoredHide(isHidden: true)
        
        if isCuted {
            MBAAudio.stopRecord()
            MBAAudio.initRecord()
            MBAAudio.startRecord()
        } else {
            MBAAudio.continueRecord()
        }
       

        time = player.duration
        initOraginTimeStatue(time: time)
        timerContinue()
        
        stopPlaying()
        
    }
    
    //停止录音
    func stopRecord() {
        MBAAudio.stopRecord()
        timerInvalidate()
    }
    
    //开始播放
    func startPlaying() {
        recoredHide(isHidden: false)
        startPlay()
    }
    
    //暂停播放
    func pausePlaying() {
        pausePlay()
    }
    
    //继续播放
    func continuePlaying() {
        continuePlay()
    }
    
    //结束播放
    func stopPlaying() {
        stopPlay()
    }
    
  
    
    /// 重新录制
    func actionReRecord() {
        let alertController = UIAlertController(title: "重新录制", message: "是否重新录制？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler:nil)
        let alertAction = UIAlertAction(title: "确定", style: .cancel, handler: { (action) in
            print("删除成功")
            self.actionReset()
        })

        alertController.addAction(cancelAction)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }

    /// 是否可录音控制
    func canRecord() -> Bool{
        var bCanRecord = true
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.requestRecordPermission { (granted) in
            bCanRecord = granted
        }
        return bCanRecord
    }

}


extension ViewController {
    
    func cutEvent() {
        // 1.拿到预处理音频文件
        
        guard let url = isCuted ? mergeExportURL : MBAAudio.url else{return}
        
        let startCutTime = 0.0
        let stopCutTime = Double(cutSlider.value)
        MBAAudioUtil.cutAudio(of: url, startTime: startCutTime, stopTime: stopCutTime) { (cutExportURL) in
            if let cutExportURL = cutExportURL {
                self.isCuted = true
                self.mergeExportURL = cutExportURL
                self.loadPlay(url: cutExportURL)
            } else {
                print("剪切失败")
            }
        }
    }
}



// MARK: - timer 一些控制
extension ViewController {
    
    func initOraginTimeStatue(time: TimeInterval){
        self.time = time
        timeLabel.text = TimeTool.getFormatTime(timerInval: TimeInterval(time))
    }
    
    func timerInit(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(actionTimer), userInfo: nil, repeats: true)
    }
    
    func timerInvalidate(){
        timer?.invalidate()
        timer = nil
    }
    
    func actionTimer() { // 60分钟，3600 秒
        time = time + 1
        initOraginTimeStatue(time:time)
        if time == 3600 {
//            结束？
        }
    }

    
    func timerPause() {
        timer?.fireDate = Date.distantFuture
    }
    
    func timerContinue() {
        timer?.fireDate = Date()
    }

}


// MARK: - AVAudioRecorderDelegate
extension ViewController: AVAudioRecorderDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("录音完成")
        }else{
            print("录音失败")
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if error != nil {
//            print(error)
        }
    }
    
}





// MARK: - PlayViewController  后修改

extension ViewController  {
    func loadPlay(url: URL?) {
        guard let url = url else {
            return
        }
        player = MBAAudioPlayer(contentsOf: url)
        player.player?.delegate = self
        initCutUI()
    }
    
    func initCutUI() {
        slider.minimumValue = 0
        slider.maximumValue = Float(player.duration)
        slider.value = 0
        cutSlider.minimumValue = 0
        cutSlider.maximumValue = Float(player.duration)
        cutSlider.value = 0
        cutSlider.isContinuous = false
        updateLabel()
    }
}
extension ViewController {
    func actionCutCancel() {
        cutBtn.isSelected = false
        cutHide(isHidden: true)
    }
    
    func actionCutYes() {
        cutBtn.isSelected = false
        cutHide(isHidden: true)
        
        cutEvent()
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
    
    func actionCut(sender: UIButton) {
        pausePlaying()
        sender.isSelected = !sender.isSelected
        if sender.isSelected { // 裁剪中
            cutHide(isHidden: false)
        } else {
            cutHide(isHidden: true)
        }        
    }
    
    func actionCutSlider(sender: UISlider) {
        slider.value = sender.value
        actionSlider(sender: sender)
    }
    
    //MARK: 点击播放
    func actionPlayClick(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected { // 播放状态
            
            if cutBtn.isSelected { // 裁剪中
                if player.currentTime == 0 {
                    actionCutSlider(sender: cutSlider)
                }else{
                    continuePlay()
                }
            }else {
                print(player.currentTime)
                player.currentTime == 0 ? startPlay() : continuePlay()
            }
            
        } else {
            pausePlay()
        }
    }

}

extension ViewController {
    func startPlay() {
        playTime = 0
        sliderTime = 0
        player?.currentTime = playTime
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
        
        if cutBtn.isSelected {
            let playTime = TimeTool.getFormatTime(timerInval: Double(cutSlider.value))
            let endTime = TimeTool.getFormatTime(timerInval: player.duration)
            timeLabel.text = "\(playTime)\\\(endTime)"
        }
    }
}
extension ViewController {
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
        let playTime = TimeTool.getFormatTime(timerInval:(player.currentTime + 0.2))//player.currentTime  第一秒0.9几
        let endTime = TimeTool.getFormatTime(timerInval: player.duration)
        timeLabel.text = "\(playTime)\\\(endTime)"
    }

}
extension ViewController {
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
        
        timerInvalidate()
    }
}

extension ViewController: AVAudioPlayerDelegate{

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("finishS")
            tipTimer?.fireDate = Date.distantFuture
        } else {
            print("finishError")
        }
    }
}
