//
//  MBACache.swift
//  bang
//
//  Created by mba on 16/10/13.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import UIKit

class MBACache {
    
    //统计缓存文件大小
    class func fileSizeOfCache()-> Int {
        // 取出cache文件夹目录 缓存文件都在这个目录下
        let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        //缓存目录路径
//        print(cachePath)
        // 取出文件夹下所有文件数组
        let fileArr = FileManager.default.subpaths(atPath: cachePath!)
        //快速枚举出所有文件名 计算文件大小
        var size = 0
        for file in fileArr! {
            // 把文件名拼接到路径中
            let path = (cachePath)! + "/\(file)"
            // 取出文件属性
            let floder = try! FileManager.default.attributesOfItem(atPath: path)
            // 用元组取出文件大小属性
            for (abc, bcd) in floder {
                // 累加文件大小
                if abc == FileAttributeKey.size {
                    size += (bcd as AnyObject).intValue
                }
            }
        }
        let mm = size / 1024 / 1024
        return mm
    }
    
    
    //删除缓存文件
    class func clearCache() {
        // 取出cache文件夹目录 缓存文件都在这个目录下
        let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        // 取出文件夹下所有文件数组
        let fileArr = FileManager.default.subpaths(atPath: cachePath!)
        // 遍历删除
        for file in fileArr! {
            
            let path = (cachePath)! + "/\(file)"
            if FileManager.default.fileExists(atPath: path) {
                
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    
                }
            }
        }
    }
    
    
    //删除录音缓存文件
    class func clearRecordCache() {
        
        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        
        let path = (docPath)! + "/record"
        if FileManager.default.fileExists(atPath: path) {
            
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
                
            }
        }
    }
    
}
