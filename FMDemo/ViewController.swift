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
    @IBOutlet weak var savaBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    var timer: Timer!
    var time = 60
    var recordTime = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordBtn.addTarget(self, action: #selector(ViewController.actionRecordClick), for: .touchUpInside)
        listenPlayBtn.addTarget(self, action: #selector(ViewController.play), for: .touchUpInside)
        savaBtn.addTarget(self, action: #selector(ViewController.stopRecord), for: .touchUpInside)
        strokeBtn.addTarget(self, action: #selector(ViewController.actionStroke), for: .touchUpInside)
    }
    
    
    func actionStroke() {
        strokeTest()
    }
    
    func strokeTest() {
//        let path = Bundle.main.url(forResource: "英雄谁属", withExtension: "mp3")
        let path = Bundle.main.url(forResource: "yijianji", withExtension: "caf")
        let songAsset = AVURLAsset(url: path!)

        let exportURL = URL(fileURLWithPath: "yijianji1.caf".docDir())
        print(exportURL)
        
        let exportSession = AVAssetExportSession(asset: songAsset, presetName: AVAssetExportPresetPassthrough)

        let startTime = CMTime(seconds: 2, preferredTimescale: 1)
        let stopTime = CMTime(seconds: 8, preferredTimescale: 1)
        let exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
        
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
            startRecord(sender)
            // 代理设为本身
            MBAAudioHelper.shared.audioRecorder.delegate = self
        }else{
            pauseRecord(sender)
        }
    }
    
    
    func play(_ sender: UIButton){
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            startPlaying(sender)
        }else{
            stopPlaying(sender)
        }
    }
    
    // MARK: - 录音状态
    //开始录音
    func startRecord(_ sender: AnyObject) {
        MBAAudioHelper.shared.startRecord()
        initOraginTimeStatue(time:1)
        timerInit()
    }
    

    //暂停录音
    func pauseRecord(_ sender: AnyObject) {
        MBAAudioHelper.shared.pauseRecord()
        timerPause()
    }
    
    //继续录音
    func continueRecord(_ sender: AnyObject) {
        MBAAudioHelper.shared.continueRecord()
        timerContinue()
    }
    
    //停止录音
    func stopRecord(_ sender: AnyObject) {
        MBAAudioHelper.shared.stopRecord()
        timerInvalidate()
    }
    
    //开始播放
    func startPlaying(_ sender: AnyObject) {
        MBAAudioHelper.shared.startPlaying()
    }
    
    //结束播放
    func stopPlaying(_ sender: AnyObject) {
        MBAAudioHelper.shared.stopPlaying()
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
    
    func initOraginTimeStatue(time: Int){
        self.time = time
//        self.cell!.recordTimeLabel.text = "\(self.time)\""
        timeLabel.text = TimeTool.getFormatTime(timerInval: TimeInterval(time))
    }
    
    func timerInit(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.timerDown), userInfo: nil, repeats: true)
    }
    
    func timerInvalidate(){
        timer.invalidate()
        timer = nil
    }
    
    func timerDown() { // 60分钟，3600 秒
        time = time + 1
        initOraginTimeStatue(time:time)
        if time == 3600 {
//            结束？
        }
    }
    
//    func timerStart() {
//        timer.fireDate = Date.distantPast
//    }
    
    func timerPause() {
        timer.fireDate = Date.distantFuture
    }
    
    func timerContinue() {
        timer.fireDate = Date()
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

