//
//  PlaySoundView.swift
//  ban
//
//  Created by mba on 16/7/21.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import UIKit
import AVFoundation

protocol PlaySoundViewDelegate : NSObjectProtocol{
    func playSoundViewClick(_ PlaySoundView: UIView)
}

class PlaySoundView: UIView {
    
    weak var delegate: PlaySoundViewDelegate?
    //申明一个媒体播放控件
    var audioPlayer: AVPlayer?
    var audioItem: AVPlayerItem?
    
    var timer: Timer?
    var audioTotalTime: TimeInterval!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }
    
    deinit {
        deinitStatus()
    }
    
    func deinitStatus() {
        audioItem?.removeObserver(self, forKeyPath: "status")
        NotificationCenter.default.removeObserver(self)
        audioItem = nil
        audioPlayer = nil
    }
    
     func setUI() {
        Bundle.main.loadNibNamed("PlaySoundView", owner: self, options: nil)
        
        self.addSubview(view)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PlaySoundView.tapAction(_:)))
        self.addGestureRecognizer(tapGestureRecognizer)
        // 自动布局要写上这句
        view.frame = bounds
        
        view.superview?.backgroundColor = UIColor.clear

        initAudio()
        setStatusUI()
        
        playBtn.addTarget(self, action: #selector(actionPlay), for: .touchUpInside)
    }
    
    
    func actionPlay() {
        
        if audioPlayer?.rate == 1 { // 在播放，点击后暂停
            playBtn.isSelected = false
            audioPlayer?.pause()
            timerPause()
        } else {
            audioPlayer?.play()
            playBtn.isSelected = true
            timerContinue()
        }
        
    }
    
    
    // xcode8 xib读取（0，0，1000，1000） 的bug
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        view.layer.cornerRadius = self.bounds.size.height/2
        view.layer.masksToBounds = true
    }
    
    
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var playNameLabel: UILabel!
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var cycleBtn: UIButton!
    @IBOutlet weak var playSlider: UISlider!
    
    func tapAction(_ sender: UITapGestureRecognizer) {
        delegate?.playSoundViewClick(self)
    }
    
    
    func setStatusUI() {
        playNameLabel.text = "yijianji.caf"
        audioTotalTime = CMTimeGetSeconds((audioPlayer?.currentItem?.asset.duration)!)
        playTimeLabel.text = TimeTool.getFormatTime(timerInval: audioTotalTime)
    }
 
}

// MARK: - timer 一些控制
extension PlaySoundView {
    
    
    func timerInit(){
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(actionTimer), userInfo: nil, repeats: true)
        timerPause()
    }
    
    func timerInvalidate(){
        timer?.invalidate()
        timer = nil
    }
    
    func actionTimer() {
        let currentTime: Float = Float(CMTimeGetSeconds((audioPlayer?.currentTime())!))
        let totalTime: Float = Float(CMTimeGetSeconds((audioPlayer?.currentItem?.asset.duration)!))
        playSlider.value = currentTime / totalTime
        let remainTime = totalTime - currentTime
        playTimeLabel.text = TimeTool.getFormatTime(timerInval: TimeInterval(remainTime))
    }
    
    
    func timerPause() {
        timer?.fireDate = Date.distantFuture
    }
    
    func timerContinue() {
        timer?.fireDate = Date()
    }

}

// MARK: - 音频播放状态设置
extension PlaySoundView {
    // 播放完成
    @objc fileprivate func playbackFinished(notice: NSNotification) {
        // 恢复最开始的0状态
        audioPlayer?.currentItem?.seek(to: CMTime(value: 0, timescale: 1))
        playBtn.isSelected = false
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if "status" == keyPath{
            guard let status = audioPlayer?.status else {
                return
            }
//            switch status as AVPlayerStatus{
//            case .unknown:
////                MBAProgressHUD.dismiss()
//            //                MBAToast.show(text: "未知状态，此时不能播放")
//            case .readyToPlay:
////                MBAProgressHUD.dismiss()
//                //                MBAToast.show(text: "准备完毕，可以播放")
//                break
//            case .failed:
////                MBAProgressHUD.dismiss()
////                MBAToast.show(text: "加载失败，网络或者服务器出现问题")
//            }
        }
    }
    
    func initAudio() {
        let path = Bundle.main.url(forResource: "yijianji", withExtension: "caf")
        
        let a = path?.lastPathComponent // 获取文件名字
//        let url = "http://i.111ttt.com:8282/97301815582.mp3"
//        let audiourl = URL(string: url)
        let audiourl = path
        audioItem = AVPlayerItem(url: audiourl!)
        audioPlayer = AVPlayer(playerItem: audioItem)
        
        audioItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackFinished(notice:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: audioItem)
        
        timerInit()
    }
}
