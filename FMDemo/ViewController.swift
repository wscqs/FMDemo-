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
    @IBOutlet weak var strokeBtn: UIButton!
    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var reRecordBtn: UIButton!
    @IBOutlet weak var savaBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var strokeSlider: UISlider!
    @IBOutlet weak var strokeCancelBtn: UIButton!
    @IBOutlet weak var strokeYesBtn: UIButton!
    

    
    var timer: Timer?
    var time:TimeInterval = 0
//    var recordTime = 0
    
    
    var playTimer: Timer?
    var playTime:TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordBtn.addTarget(self, action: #selector(actionRecordClick), for: .touchUpInside)
        recordBtn.setTitle("开始录音", for: .normal)
        recordBtn.setTitle("录音中", for: .selected)
        
        listenPlayBtn.addTarget(self, action: #selector(play), for: .touchUpInside)
        savaBtn.addTarget(self, action: #selector(stopRecord), for: .touchUpInside)
        strokeBtn.addTarget(self, action: #selector(actionStroke), for: .touchUpInside)
        
        reRecordBtn.addTarget(self, action: #selector(actionReRecord), for: .touchUpInside)
        
        slider.addTarget(self, action: #selector(sliderChangeValue), for: .valueChanged)
        slider.isContinuous = false // 滑动结束 才会执行valueChanged 事件
        

        strokeSlider.isContinuous = false
        strokeSlider.value = 0
        strokeSlider.addTarget(self, action: #selector(strokeSliderChangeValue), for: .valueChanged)
        strokeCancelBtn.addTarget(self, action: #selector(actionStrokeCancel), for: .touchUpInside)
        strokeYesBtn.addTarget(self, action: #selector(actionStrokeYes), for: .touchUpInside)

        initStatusHide(isHidden: true)
    }
    
    func actionStrokeCancel() {
        strokeHide(isHidden: true)
    }
    
    func actionStrokeYes() {
        strokeTest()
    }
    
    /// 截图的隐藏
    func strokeHide(isHidden: Bool) {
        strokeCancelBtn.isHidden = isHidden
        strokeYesBtn.isHidden = isHidden
        strokeSlider.isHidden = isHidden
    }
    
    /// 录音的隐藏
    func recoredHide(isHidden: Bool) {
        listenPlayBtn.isHidden = isHidden
        strokeBtn.isHidden = isHidden
    }
    
    func initStatusHide(isHidden: Bool) {
        recoredHide(isHidden: true)
        strokeHide(isHidden: true)
        recoredHide(isHidden: true)
        noRecordHide(isHidden: true)
    }
    
    /// 未录音时隐藏
    func noRecordHide(isHidden: Bool) {
        reRecordBtn.isHidden = isHidden
        savaBtn.isHidden = isHidden
    }

    

    
    /// 裁剪
    func actionStroke() {
        strokeHide(isHidden: false)
        
        pausePlaying()
        listenPlayBtn.isSelected = false
        
    }
    
    func strokeTest() {
        // 1.拿到预处理音频文件
        let path = Bundle.main.url(forResource: "yijianji", withExtension: "caf")
        let songAsset = AVURLAsset(url: path!)

        let exportPath = "yijianji1.caf".docDir()
        let exportURL = URL(fileURLWithPath: exportPath)
        print(exportURL)
        
        // 2.创建新的音频文件
        if FileManager.default.fileExists(atPath: exportPath) {
            try? FileManager.default.removeItem(atPath: exportPath)
        }
        
        // 3.创建音频输出会话
        let exportSession = AVAssetExportSession(asset: songAsset, presetName: AVAssetExportPresetPassthrough)

        let startTime = CMTime(seconds: 2, preferredTimescale: 1)
        let stopTime = CMTime(seconds: 8, preferredTimescale: 1)
        let exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
         // 4.设置音频输出会话并执行
        exportSession?.outputURL = exportURL
        exportSession?.outputFileType = AVFileTypeCoreAudioFormat
        exportSession?.timeRange = exportTimeRange
        exportSession?.exportAsynchronously {
            if AVAssetExportSessionStatus.completed == exportSession?.status {
                print("AVAssetExportSessionStatusCompleted")
            } else if AVAssetExportSessionStatus.failed == exportSession?.status {
                print("AVAssetExportSessionStatusFailed")
            } else {
                 print("Export Session Status: %d", exportSession?.status ?? "")
            }
        }
        
    }
    
    func strokeSliderChangeValue(sender: UISlider) {
        slider.value = sender.value
        playTime = TimeInterval(sender.value)
        initPlayInitTimeStatue(time: playTime)
    }
    
    func sliderChangeValue(sender: UISlider) {
        playTime = TimeInterval(sender.value)
        initPlayInitTimeStatue(time: playTime)
        playTimerContinue()
        MBAAudio.play(atTime: playTime)
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
            MBAAudio.audioPlayer == nil ? startPlaying() : continuePlaying()
        }else{
            pausePlaying()
        }
    }
    
    // MARK: - 录音状态
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
    }
    
    //继续录音
    func continueRecord() {
        recoredHide(isHidden: true)
        
        MBAAudio.continueRecord()
        timerContinue()
        
        initOraginTimeStatue(time: time)
        
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
        
        MBAAudio.startPlaying()
        slider.maximumValue = Float(time)
        slider.minimumValue = 0
        initPlayInitTimeStatue(time: 0)
        
//        slider.maximumValue = Float(MBAAudio.audioPlayerDuration)
//        slider.minimumValue = 0
//        initPlayInitTimeStatue(time: MBAAudio.audioPlayerCurrentTime)
        playTimerInit()
    }
    
    //暂停播放
    func pausePlaying() {
        MBAAudio.pausePlaying()
        playTimerPause()
    }
    
    //继续播放
    func continuePlaying() {
        MBAAudio.continuePlaying()
        playTimerContinue()
        initPlayInitTimeStatue(time: playTime)
//        initPlayInitTimeStatue(time: MBAAudio.audioPlayerCurrentTime)
    }
    
    //结束播放
    func stopPlaying() {
        MBAAudio.stopPlaying()
        playTimerInvalidate()
        listenPlayBtn.isSelected = false
    }
    
  
    
    /// 重新录制
    func actionReRecord() {
        let alertController = UIAlertController(title: "重新录制", message: "是否重新录制？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler:nil)
        let alertAction = UIAlertAction(title: "确定", style: .cancel, handler: { (action) in
            if MBAAudio.deleteRecording() {
                print("删除成功")
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

// MARK: - timer 一些控制
extension ViewController {
    
    func initOraginTimeStatue(time: TimeInterval){
        self.time = time
//        self.cell!.recordTimeLabel.text = "\(self.time)\""
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
    
    
    
    func initPlayInitTimeStatue(time: TimeInterval){
        self.playTime = time
        let endTime = TimeTool.getFormatTime(timerInval: self.time)
        let startTime = TimeTool.getFormatTime(timerInval: self.playTime)
//        slider.value = Float(MBAAudio.audioPlayerCurrentTime)
        slider.value = Float(time)
        timeLabel.text = "\(startTime)\\\(endTime)"
    }
    
    func playTimerInit(){
        playTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(actionPlayTimer), userInfo: nil, repeats: true)
    }
    
    func playTimerInvalidate(){
        playTimer?.invalidate()
        playTimer = nil
    }
    
    func actionPlayTimer() {
        playTime = playTime + 1
        initPlayInitTimeStatue(time:playTime)
        
        if playTime >= self.time {
            //            结束？
            stopPlaying()
        }
//                playTime = MBAAudio.audioPlayerCurrentTime
//                initPlayInitTimeStatue(time:playTime)
//        
//                if playTime >= self.time {
//                    //            结束？
//                    stopPlaying()
//                }
    }
    
    func playTimerPause() {
        playTimer?.fireDate = Date.distantFuture
    }
    
    func playTimerContinue() {
        playTimer?.fireDate = Date()
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

