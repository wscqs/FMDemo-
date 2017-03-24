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

class MBAAudioUtil {
    
    /// 剪切
    ///
    /// - Parameter url: 音频的url
    /// - Returns: 剪切成功后的URL，失败返回nil
    class func cutAudio(of url: URL,
                  startTime: TimeInterval,
                  stopTime: TimeInterval,
                  handleComplet: @escaping (_ exportURL: URL?)->Void){
        
        let cutExportPath = (Date().formatDate + ".caf").docRecordDir()
        let exportURL = URL(fileURLWithPath: cutExportPath)
        print(exportURL)
        
        // 2.创建新的音频文件
        if FileManager.default.fileExists(atPath: cutExportPath) {
            try? FileManager.default.removeItem(atPath: cutExportPath)
        }
        
        let songAsset = AVURLAsset(url: url)
        // 3.创建音频输出会话
        let exportSession = AVAssetExportSession(asset: songAsset, presetName: AVAssetExportPresetPassthrough)

        let startTime = CMTime(seconds: startTime, preferredTimescale: 1000)
        let stopTime = CMTime(seconds: stopTime, preferredTimescale: 1000)
        let exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
        // 4.设置音频输出会话并执行
        exportSession?.outputURL = exportURL
        exportSession?.outputFileType = AVFileTypeCoreAudioFormat
        exportSession?.timeRange = exportTimeRange
        exportSession?.exportAsynchronously {
            if AVAssetExportSessionStatus.completed == exportSession?.status {
                print("AVAssetExportSessionStatusCompleted")
                
                DispatchQueue.main.async {
                    return handleComplet(exportURL)
                }
            } else if AVAssetExportSessionStatus.failed == exportSession?.status {
                print("AVAssetExportSessionStatusFailed")
            } else {
                print("Export Session Status: %d", exportSession?.status ?? "")
            }
        }
    }
    
    /// 合并音频
    ///
    /// - Parameters:
    ///   - url1: 音频1 url
    ///   - url2: 音频2 url
    ///   - handleComplet: 合并成功后的URL，失败返回nil
    class func mergeAudio(url1: URL,
                    url2: URL,
                    handleComplet: @escaping (_ exportURL: URL?)->Void){
        
        let audioAsset1 = AVURLAsset(url: url1)
        let audioAsset2 = AVURLAsset(url: url2)
        
        let composititon = AVMutableComposition()
        try? composititon.insertTimeRange(CMTimeRangeMake(kCMTimeZero, audioAsset1.duration), of: audioAsset1, at: kCMTimeZero)
        try? composititon.insertTimeRange(CMTimeRangeMake(kCMTimeZero, audioAsset2.duration), of: audioAsset2, at: audioAsset1.duration)
        
        
        
        let mergeExportPath = (Date().formatDate + ".caf").docRecordDir()
        let exportURL = URL(fileURLWithPath: mergeExportPath)
        
        
        // 3.创建音频输出会话
        let exportSession = AVAssetExportSession(asset: composititon, presetName: AVAssetExportPresetPassthrough)
        // 4.设置音频输出会话并执行
        exportSession?.outputURL = exportURL
        exportSession?.outputFileType = AVFileTypeCoreAudioFormat
        exportSession?.exportAsynchronously {
            if AVAssetExportSessionStatus.completed == exportSession?.status {
                print("AVAssetExportSessionStatusCompleted")
                print(mergeExportPath)
                DispatchQueue.main.async {
                    return handleComplet(exportURL)
                }
            } else {
                DispatchQueue.main.async {
                    return handleComplet(nil)
                }
            }
//            else if AVAssetExportSessionStatus.failed == exportSession?.status {
//                print("AVAssetExportSessionStatusFailed")
//            } else {
//                print("Export Session Status: %d", exportSession?.status ?? "")
//            }
        }
    }
    
    
    class func changceToMp3(of cafURL: URL?,mp3Name: String) -> URL?{

        guard let cafURL = cafURL else{
            return nil
        }
        let cafURL1 = URL(string: cafURL.path)
        let mp3Name1 = mp3Name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let path2 = (mp3Name1! + ".mp3").docSaveRecordDir()
        let mp3URL = URL(fileURLWithPath: path2)
        
        Lame2mp3Tool.transformCAFPath(cafURL1, toMP3: mp3URL)
        return mp3URL
    }

}
