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

//public typealias AudioRecordHandler = (_ response: SKProductsResponse?, _ error: Error?) -> ()

class MBAAudioHelper: NSObject {
    
    /// 转化后路径
    public var mp3AudioString: String!
    public var cafAudioString: String!
    
    private override init() {
        super.init()
        audioSession = AVAudioSession.sharedInstance()
//        setInitData()
    }
    static let shared = MBAAudioHelper()

    
    // MARK: - var
    var audioSession:AVAudioSession!
    var audioRecorder:AVAudioRecorder?
    var audioPlayer:AVAudioPlayer?

    
    ////定义音频的编码参数，这部分比较重要，决定录制音频文件的格式、音质、容量大小等，建议采用AAC的编码方式
    let recordSettings = [AVFormatIDKey : NSNumber(value: Int32(kAudioFormatLinearPCM) as Int32),//设置录音格式
        AVSampleRateKey : NSNumber(value: Float(11025.0)),//设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）, 采样率必须要设为11025才能使转化成mp3格式后不会失真
        AVNumberOfChannelsKey : NSNumber(value: 2 as Int),//录音通道数  1 或 2 ，要转换成mp3格式必须为双通道
        AVEncoderAudioQualityKey : NSNumber(value: Int(AVAudioQuality.high.rawValue)),//音频质量
        AVLinearPCMBitDepthKey : NSNumber(value: 16 as Int)//采样位数 默认 16
    ]

     func initRecord() {
        //根据时间设置存储文件名
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyyHHmmss"
        let recordingName = formatter.string(from: currentDateTime)+".caf"
        cafAudioString = recordingName.docRecordDir()
        print(cafAudioString)
        mp3AudioString = (formatter.string(from: currentDateTime) + ".mp3").docRecordDir()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioRecorder = AVAudioRecorder(url: URL(string: cafAudioString)!,                                                settings: recordSettings)//初始化实例
//            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()//准备录音
        } catch {
        }
    }

}

// MARK: - API
extension MBAAudioHelper{
    // MARK: - 录音状态
    /// 开始录音
    func startRecord() {
        do {
            try audioSession.setActive(true)
            audioRecorder?.record()
            print("startRecord!")
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
        print("pauseRecord!!")
        audioRecorder?.pause()
    }
    
    /// 继续录音
    func continueRecord() {
        print("continueRecord!!")
        audioRecorder?.record()
    }
    
    
    /// 停止录音
    func stopRecord() {
        audioRecorder?.stop()
        audioRecorder = nil
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(false)
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

    /// 开始播放
    func startPlaying() {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: (audioRecorder?.url)!)
            audioPlayer?.play()
            print("startPlaying!!")
        } catch {
            print("playError!!")
        }
    }
    
    /// 是否播放
    var isPlaying:Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    /// 暂停播放
    func pausePlaying() {
        print("pausePlaying!!")
        audioPlayer?.pause()
    }
    
    /// 继续播放
    func continuePlaying() {
        print("continuePlaying!!")
        audioPlayer?.play()
    }
    
    /// 停止播放
    func stopPlaying() {
        print("stopPlaying!!")
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    /// 从指定时间播放
    ///
    /// - Parameter atTime:指定时间
    func play(atTime: TimeInterval) {
//        audioPlayer?.play(atTime: (audioPlayer?.deviceCurrentTime)! + atTime) // 这是延迟atTime 时间执行!
        audioPlayer?.currentTime = atTime
        audioPlayer?.play()
    }
    

    
//    func cafChangceToMp3(){
//        let cafPath = URL(string: cafAudioString)
//        let mp3Path = URL(string: mp3AudioString)
//        Lame2mp3Tool.transformCAFPath(cafPath!, toMP3: mp3Path!)
//    }
    
    
}
