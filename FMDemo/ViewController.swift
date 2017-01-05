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

    @IBOutlet var heartButton: DOFavoriteButton!
    
    
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
    

    var addBtn: UIButton = UIButton()
    
    var timer: Timer?
    var time:TimeInterval = 0
    
    
    var playTimer: Timer?
    var playTime:TimeInterval = 0
    
    
//    var playTime: TimeInterval!
    var sliderTime: TimeInterval!
    var sliderTimer: Timer?
    var tipTimer: Timer?
    var player: AVAudioPlayer!
    
    
    func add() {

        let path1 = "05012017161357.caf".docRecordDir()
        let path2 = "05012017160800.caf".docRecordDir()
        let audioAsset1 = AVURLAsset(url: URL(fileURLWithPath: path1))
        let audioAsset2 = AVURLAsset(url: URL(fileURLWithPath: path2))

        
        
//        let audioAssetTrack1 = audioAsset1.tracks(withMediaType: AVMediaTypeAudio).first!
//        let audioAssetTrack2 = audioAsset2.tracks(withMediaType: AVMediaTypeAudio).first!
//        let audioTrack1 = composititon.addMutableTrack(withMediaType: AVAssetExportPresetPassthrough, preferredTrackID: kCMPersistentTrackID_Invalid)
//        let audioTrack2 = composititon.addMutableTrack(withMediaType: AVAssetExportPresetPassthrough, preferredTrackID: kCMPersistentTrackID_Invalid)
//
//        
//        try? audioTrack1.insertTimeRange(CMTimeRangeMake(kCMTimeZero, audioAsset1.duration), of: audioAssetTrack1, at: kCMTimeZero)
//        try? audioTrack2.insertTimeRange(CMTimeRangeMake(kCMTimeZero, audioAsset2.duration), of: audioAssetTrack2, at: audioAsset1.duration)
        
        let composititon = AVMutableComposition()
        try? composititon.insertTimeRange(CMTimeRangeMake(kCMTimeZero, audioAsset1.duration), of: audioAsset1, at: kCMTimeZero)
        try? composititon.insertTimeRange(CMTimeRangeMake(kCMTimeZero, audioAsset2.duration), of: audioAsset2, at: audioAsset1.duration)
        
        

        let exportPath = (Date().formatDate + ".caf").docDir()
        let exportURL = URL(fileURLWithPath: exportPath)
        print(exportURL)
        
//        let exportSession = AVAssetExportSession(asset: compostiton, presetName: AVAssetExportPresetAppleM4A)
//        exportSession?.outputURL = exportURL
//        exportSession?.outputFileType = AVFileTypeAppleM4A
        
        
        // 3.创建音频输出会话
        let exportSession = AVAssetExportSession(asset: composititon, presetName: AVAssetExportPresetPassthrough)
        // 4.设置音频输出会话并执行
        exportSession?.outputURL = exportURL
        exportSession?.outputFileType = AVFileTypeCoreAudioFormat
        exportSession?.exportAsynchronously {
            if AVAssetExportSessionStatus.completed == exportSession?.status {
                print("AVAssetExportSessionStatusCompleted")
                
                DispatchQueue.main.async {
                    self.loadPlay(url: exportURL)
                }
            } else if AVAssetExportSessionStatus.failed == exportSession?.status {
                print("AVAssetExportSessionStatusFailed")
                print(exportSession?.error.debugDescription)
            } else {
                print("Export Session Status: %d", exportSession?.status ?? "")
            }
        }
    }
    
    func trans() {
        MBAAudioHelper.shared.cafChangceToMp3()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(addBtn)
        addBtn.setTitle("合并", for: .normal)
        addBtn.setTitleColor(UIColor.blue, for: .normal)
        addBtn.center = view.center
        addBtn.sizeToFit()
        addBtn.addTarget(self, action: "trans", for: .touchUpInside)
        recordBtn.addTarget(self, action: #selector(actionRecordClick), for: .touchUpInside)
        recordBtn.setTitle("开始录音", for: .normal)
        recordBtn.setTitle("录音中", for: .selected)
        
        listenPlayBtn.addTarget(self, action: #selector(actionPlayClick), for: .touchUpInside)

        
        savaBtn.addTarget(self, action: #selector(stopRecord), for: .touchUpInside)
        cutBtn.addTarget(self, action: #selector(actionCut), for: .touchUpInside)
        
        reRecordBtn.addTarget(self, action: #selector(actionReRecord), for: .touchUpInside)
        
        slider.addTarget(self, action: #selector(actionSlider), for: .valueChanged)

        slider.isContinuous = false // 滑动结束 才会执行valueChanged 事件
        

        cutSlider.isContinuous = false
        cutSlider.value = 0
        cutSlider.addTarget(self, action: #selector(actionCutSlider), for: .valueChanged)
        
        cutCancelBtn.addTarget(self, action: #selector(actionStrokeCancel), for: .touchUpInside)
        cutYesBtn.addTarget(self, action: #selector(actionStrokeYes), for: .touchUpInside)

        initStatusHide(isHidden: true)
    }
    
    func actionStrokeCancel() {
        cutHide(isHidden: true)
    }
    
    func actionStrokeYes() {
        cutEvent()
    }
    
    /// 截取的隐藏
    func cutHide(isHidden: Bool) {
        cutCancelBtn.isHidden = isHidden
        cutYesBtn.isHidden = isHidden
        cutSlider.isHidden = isHidden
    }
    
    /// 录音的隐藏
    func recoredHide(isHidden: Bool) {
        listenPlayBtn.isHidden = isHidden
        cutBtn.isHidden = isHidden
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
    
    
    func play(_ sender: UIButton){
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            print(MBAAudio.audioPlayerCurrentTime,MBAAudio.audioPlayerDuration,"aaaaa")
            (MBAAudio.audioPlayerCurrentTime == 0 || MBAAudio.audioPlayerCurrentTime == MBAAudio.audioPlayerDuration) ? startPlaying() : continuePlaying()
        }else{
            pausePlaying()
        }
    }
    
    // MARK: - 录音状态
//    func initRecordStatus() {
//        initStatusHide(isHidden: true)
//        
//    }
    
    //开始录音
    func startRecord() {
        noRecordHide(isHidden: false)
        recoredHide(isHidden: true)
        
        MBAAudio.initRecord()
        MBAAudio.startRecord()
        initOraginTimeStatue(time:0)
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
        recoredHide(isHidden: false)
        
        // 初始化歌曲
//        MBAAudio.initPlayer()
        loadPlay(url: MBAAudio.audioRecorder?.url)
    }
    
    //继续录音
    func continueRecord() {
        recoredHide(isHidden: true)
        
        MBAAudio.continueRecord()

        time = player.duration 
        initOraginTimeStatue(time: time)
        timerContinue()
        
        stopPlaying()
        
        recoredHide(isHidden: true)
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
            if MBAAudio.deleteRecording() {
                print("删除成功")
                self.initStatusHide(isHidden: true)
                MBAAudio.audioRecorder = nil
                self.recordBtn.setTitle("录音", for: .normal)
                self.recordBtn.isSelected = false                
            } else {
                 print("删除失败")
            }
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
        let inputPath = MBAAudio.audioRecorder?.url.absoluteString
        let url = URL(fileURLWithPath: inputPath!)
        let songAsset = AVURLAsset(url: url)
        
        let exportPath = (Date().formatDate + ".caf").docCutDir()
        let exportURL = URL(fileURLWithPath: exportPath)
        print(exportURL)
        
        // 2.创建新的音频文件
        if FileManager.default.fileExists(atPath: exportPath) {
            try? FileManager.default.removeItem(atPath: exportPath)
        }
        
        // 3.创建音频输出会话
        let exportSession = AVAssetExportSession(asset: songAsset, presetName: AVAssetExportPresetPassthrough)
        
        let startCutTime = cutSlider.value
        let stopCutTime = player.duration
        let startTime = CMTime(seconds: Double(startCutTime), preferredTimescale: 1000)
        let stopTime = CMTime(seconds: stopCutTime, preferredTimescale: 1000)
        let exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
        // 4.设置音频输出会话并执行
        exportSession?.outputURL = exportURL
        exportSession?.outputFileType = AVFileTypeCoreAudioFormat
        exportSession?.timeRange = exportTimeRange
        exportSession?.exportAsynchronously {
            if AVAssetExportSessionStatus.completed == exportSession?.status {
                print("AVAssetExportSessionStatusCompleted")
                
                DispatchQueue.main.async {
                    self.loadPlay(url: exportURL)
                }
            } else if AVAssetExportSessionStatus.failed == exportSession?.status {
                print("AVAssetExportSessionStatusFailed")
            } else {
                print("Export Session Status: %d", exportSession?.status ?? "")
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
        player = try? AVAudioPlayer(contentsOf: url!)
        player.delegate = self
        player.prepareToPlay()
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
        player.currentTime = playTime
        updateLabel()
        player.play()
        
        initTimer()
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
        sliderTimer?.fireDate = Date.distantFuture
        listenPlayBtn.isSelected = false
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
        print((player.currentTime + 0.1) ,player.duration)
        let playTime = TimeTool.getFormatTime(timerInval:(player.currentTime + 0.1))//player.currentTime  第一秒0.9几
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


















// MARK: - 点赞，收藏等效果
extension ViewController {

    func setUI() {
        let width = (self.view.frame.width - 44) / 4
        let x = width / 2
        let y = self.view.frame.height / 2 - 22
        
        var btnRect = CGRect(x: x, y: y, width: 44, height: 44)
        // star button
        
        let starButton = DOFavoriteButton(frame: btnRect, image: UIImage(named: "star"))
        starButton.addTarget(self, action: #selector(ViewController.tappedButton), for: .touchUpInside)
        self.view.addSubview(starButton)
        btnRect.origin.x += width
        
        // heart button
        let heartButton = DOFavoriteButton(frame: btnRect, image: UIImage(named: "heart"))
        heartButton.imageColorOn = UIColor(red: 254/255, green: 110/255, blue: 111/255, alpha: 1.0)
        heartButton.circleColor = UIColor(red: 254/255, green: 110/255, blue: 111/255, alpha: 1.0)
        heartButton.lineColor = UIColor(red: 226/255, green: 96/255, blue: 96/255, alpha: 1.0)
        heartButton.addTarget(self, action: #selector(ViewController.tappedButton), for: .touchUpInside)
        self.view.addSubview(heartButton)
        btnRect.origin.x += width
        
        // like button
        let likeButton = DOFavoriteButton(frame: btnRect, image: UIImage(named: "like"))
        likeButton.imageColorOn = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)
        likeButton.circleColor = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)
        likeButton.lineColor = UIColor(red: 41/255, green: 128/255, blue: 185/255, alpha: 1.0)
        likeButton.addTarget(self, action: #selector(ViewController.tappedButton), for: .touchUpInside)
        self.view.addSubview(likeButton)
        btnRect.origin.x += width
        
        // smile button
        let smileButton = DOFavoriteButton(frame: btnRect
            , image: UIImage(named: "smile"))
        smileButton.imageColorOn = UIColor(red: 45/255, green: 204/255, blue: 112/255, alpha: 1.0)
        smileButton.circleColor = UIColor(red: 45/255, green: 204/255, blue: 112/255, alpha: 1.0)
        smileButton.lineColor = UIColor(red: 45/255, green: 195/255, blue: 106/255, alpha: 1.0)
        smileButton.addTarget(self, action: #selector(ViewController.tappedButton), for: .touchUpInside)
        self.view.addSubview(smileButton)
        
        self.heartButton.addTarget(self, action: #selector(ViewController.tappedButton), for: .touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tappedButton(sender: DOFavoriteButton) {
        if sender.isSelected {
            sender.deselect()
        } else {
            sender.select()
        }
    }
}

