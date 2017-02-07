//
//  TestViewController.swift
//  FMDemo
//
//  Created by mba on 17/2/6.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit
import AVFoundation

class TestViewController: UIViewController {

    var addDubBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("开始录音", for: .normal)
        btn.setTitleColor(UIColor.lightGray, for: .normal)
        btn.sizeToFit()
        btn.addTarget(self, action: #selector(TestViewController.actionRecord), for: .touchUpInside)
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(addDubBtn)
        addDubBtn.center = view.center
    }
    
    
    // MARK: - var
    var audioSession:AVAudioSession?
    var audioRecorder:AVAudioRecorder?
    var cafAudioString = ""
    
    
    ////定义音频的编码参数，这部分比较重要，决定录制音频文件的格式、音质、容量大小等，建议采用AAC的编码方式
    let recordSettings: [String : Any] = [AVFormatIDKey : Int(kAudioFormatLinearPCM),//设置录音格式
        AVSampleRateKey : Float(11025.0),//设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）, 采样率必须要设为11025才能使转化成mp3格式后不会失真
        AVNumberOfChannelsKey : 2,//录音通道数  1 或 2 ，要转换成mp3格式必须为双通道
        AVEncoderAudioQualityKey : Int(AVAudioQuality.high.rawValue),//音频质量
        AVLinearPCMBitDepthKey : 16//采样位数 默认 16
    ]
    
    
    func initRecord() {
        audioSession = AVAudioSession.sharedInstance()
        //根据时间设置存储文件名
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyyHHmmss"
        let recordingName = formatter.string(from: currentDateTime)+".caf"
        cafAudioString = recordingName.tmpDir()
        //        print(cafAudioString)
        //        mp3AudioString = (formatter.string(from: currentDateTime) + ".mp3").docRecordDir()
        
        do {
            try audioSession?.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession?.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker) // 解决音频声音播放过小
            try audioRecorder = AVAudioRecorder(url: URL(string: cafAudioString)!,                                                settings: recordSettings)//初始化实例
            audioRecorder?.isMeteringEnabled = true
            //            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()//准备录音
        } catch {
            print(error)
        }
    }
    
    
    var timer = Timer()
    var time = 0
    
    func actionRecord() {
        initRecord()
        audioRecorder?.record()
        // 画音波的计时器
//        timer = Timer.scheduledTimer(timeInterval: kWaveTime, target: self, selector: #selector(timerEvent), userInfo: nil, repeats: true)
        
    }
    
//    func timerEvent() {
//        print(audioPowerChange())
//    }
    
    
    func audioPowerChange() -> Float{
        audioRecorder?.updateMeters()//更新测量值
        //        let power = audioRecorder?.peakPower(forChannel: 0)
        let peakPowerForChannel = audioRecorder?.averagePower(forChannel: 0)//取得第一个通道的音频，注意音频强度范围时-160到0
        let power = pow(10, (0.05 * (peakPowerForChannel ?? 0)))
//        print(power)
//        let progress = (1.0/160.0)*((power ?? 0) + 160.0)
        return power
    }
}
