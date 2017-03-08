//
//  MBAPlayerHelper.swift
//  bang
//
//  Created by mba on 16/10/25.
//  Copyright © 2016年 mbalib. All rights reserved.
//

// 播放的帮助类

import Foundation
import AVFoundation

class MBAAudioPlayer {

    // MARK: - var
    var player:AVAudioPlayer?
    var duration: TimeInterval{
        return player?.duration ?? 0
    }
    
    var currentTime: TimeInterval {
        set{
            player?.currentTime = newValue
        }
        get{
            return player?.currentTime ?? 0
        }        
    }
    
    var volume: Float {
        set{
            player?.volume = newValue
        }
        get{
            return player?.volume ?? 0
        }
    }
    
    // -1 为循环
    var numberOfLoops: Int = 0 {
        didSet{
            player?.numberOfLoops = numberOfLoops
        }
    }
    
    /// 是否播放
    var isPlaying:Bool {
        return player?.isPlaying ?? false
    }

    convenience init(contentsOf url: URL) {
        self.init()
        do {
            try player = AVAudioPlayer(contentsOf: url)
            player?.isMeteringEnabled = true
            player?.prepareToPlay()
//            print("initPlayer!!")
        } catch {
            print("initPlayerError!!")
        }
    }

}

// MARK: - API
extension MBAAudioPlayer{

    /// 开始播放
    func startPlay() {
//        print("startPlay!!")
        play(atTime: 0)
    }

    /// 暂停播放
    func pausePlay() {
//        print("pausePlaying!!")
        player?.pause()
    }
    
    /// 继续播放
    func continuePlay() {
//        print("continuePlaying!!")
        player?.play()
    }
    
    /// 停止播放
    func stopPlay() {
//        print("stopPlaying!!")
        player?.stop()
        player = nil
    }
    
    /// 从指定时间播放
    ///
    /// - Parameter atTime:指定时间
    func play(atTime: TimeInterval) {
//        player?.play(atTime: (player?.deviceCurrentTime)! + atTime) // 这是延迟atTime 时间执行!
        player?.currentTime = atTime
        player?.play()
    }
    
    
    func audioPowerChange() -> Float{
        player?.updateMeters()//更新测量值
        let peakPowerForChannel = player?.peakPower(forChannel: 0)
        //        let peakPowerForChannel = audioRecorder?.averagePower(forChannel: 0)//取得第一个通道的音频，注意音频强度范围时-160到0
        //        let progress = (1.0/160.0)*(power! + 160.0)
        let progress = pow(10, (0.05 * (peakPowerForChannel ?? 0)))
        return progress
    }
   
}


