//
//  MBAAudioHelper.swift
//  bang
//
//  Created by mba on 16/10/25.
//  Copyright © 2016年 mbalib. All rights reserved.
//

// 录音的帮助类

import Foundation
import AVFoundation

let MBAAudio = MBAAudioHelper.shared

class MBAAudioHelper: NSObject {
    
    public var cafAudioString: String = ""
    
    var url:URL? {
        return URL(fileURLWithPath: cafAudioString)
    }
    
    private override init() {
        super.init()
        audioSession = AVAudioSession.sharedInstance()
//        setInitData()
    }
    static let shared = MBAAudioHelper()

    
    // MARK: - var
    var audioSession:AVAudioSession?
    var audioRecorder:AVAudioRecorder?

    
    ////定义音频的编码参数，这部分比较重要，决定录制音频文件的格式、音质、容量大小等，建议采用AAC的编码方式
    let recordSettings: [String : Any] = [AVFormatIDKey : Int(kAudioFormatLinearPCM),//设置录音格式
        AVSampleRateKey : Float(44100),//设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）, 采样率必须要设为11025才能使转化成mp3格式后不会失真
        AVNumberOfChannelsKey : 2,//录音通道数  1 或 2 ，要转换成mp3格式必须为双通道
        AVEncoderAudioQualityKey : Int(AVAudioQuality.medium.rawValue),//音频质量
        AVLinearPCMBitDepthKey : 16//采样位数 默认 16
    ]
    

     func initRecord() {
        //根据时间设置存储文件名
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyyHHmmss"
        let recordingName = formatter.string(from: currentDateTime)+".caf"
        cafAudioString = recordingName.docRecordDir()
        print(cafAudioString)
        
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

}

// MARK: - API
extension MBAAudioHelper{
    // MARK: - 录音状态
    /// 开始录音
    func startRecord() {
        
        stopRecord()
        initRecord()
        
        do {
            try audioSession?.setActive(true)
            audioRecorder?.record()
//            print("startRecord!")
        } catch {
            print("recordError!")
        }
    }
    
    /// 是否正在录音
    var isRecording:Bool {
        return audioRecorder?.isRecording ?? false
    }
    
    /// 暂停录音
    func pauseRecord() {
//        print("pauseRecord!!")
        audioRecorder?.pause()
    }
    
    /// 继续录音
    func continueRecord() {
//        print("continueRecord!!")
        audioRecorder?.record()
    }

    /// 停止录音
    func stopRecord() {
        audioRecorder?.stop()
//        audioRecorder = nil
        do {
            try audioSession?.setCategory(AVAudioSessionCategoryPlayback)//此处需要恢复设置回放标志，否则会导致其它播放声音也会变小
            try audioSession?.setActive(true)
            print("stop!!")
        } catch {
            print("stopError!!")
        }
    }
    
    /// 删除录音
    ///
    /// - Returns: 是否删除成功
    func deleteRecording() -> Bool {
        return audioRecorder?.deleteRecording() ?? false
    }
    
    func audioPowerChange() -> Float{
        audioRecorder?.updateMeters()//更新测量值
        let peakPowerForChannel = audioRecorder?.peakPower(forChannel: 0)
//        let peakPowerForChannel = audioRecorder?.averagePower(forChannel: 0)//取得第一个通道的音频，注意音频强度范围时-160到0
//        let progress = (1.0/160.0)*(power! + 160.0)
        let progress = pow(10, (0.05 * (peakPowerForChannel ?? 0)))
        return progress
    }

}
