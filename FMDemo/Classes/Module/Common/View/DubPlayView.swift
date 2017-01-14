//
//  DubPlayView.swift
//  ban
//
//  Created by mba on 16/7/21.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import UIKit
import AVFoundation

protocol DubPlayViewDelegate : NSObjectProtocol{
    func volumeBtnClick(_ dubPlayView: DubPlayView)
    func changceDubClick(_ dubPlayView: DubPlayView)
}

class DubPlayView: UIView {
    
    weak var delegate: DubPlayViewDelegate?
    //申明一个媒体播放控件
    var audioPlayer: AVPlayer?
    var audioItem: AVPlayerItem?
    
    var timer: Timer?
    var audioTotalTime: TimeInterval!
    
    var isCycle = false
    
    var volume :Int? {
        didSet{
            guard let volume = volume else {
                return
            }
            audioPlayer?.volume = (Float(volume) / 100)
            changceVolumeBtn.setTitle("\(volume)%\n声音", for: .normal)
        }
    }
    
    class func dubPlayView() -> DubPlayView{
        return Bundle.main.loadNibNamed("DubPlayView", owner: self, options: nil)?.last as! DubPlayView
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setUI()
//    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setUI()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
    
    func initStatus(){
        playBtn.isSelected = false
    }
    
    func setUI() {
        playBtn.addTarget(self, action: #selector(actionPlay), for: .touchUpInside)
        changceVolumeBtn.addTarget(self, action: #selector(DubPlayView.actionChangceVolume), for: .touchUpInside)
        changceDubBtn.addTarget(self, action: #selector(DubPlayView.actionChangceDub), for: .touchUpInside)
        cycleBtn.addTarget(self, action: #selector(DubPlayView.actionCycle), for: .touchUpInside)
        cycleBtn.setTitle("未循环", for: .normal)
        cycleBtn.setTitle("循环", for: .selected)
        timerInit()
    }
    
    func actionCycle(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        isCycle = sender.isSelected
    }
    
    func actionPlay() {
        
        if audioPlayer?.rate == 1 { // 在播放，点击后暂停
            playPause()
        } else {
            audioPlayer?.play()
            playBtn.isSelected = true
            timerContinue()
        }
    }
    
    func playPause() {
        playBtn.isSelected = false
        audioPlayer?.pause()
        timerPause()
    }
    
    func actionChangceVolume(sender: UIButton) {
        delegate?.volumeBtnClick(self)
    }
    func actionChangceDub(sender: UIButton) {
        delegate?.changceDubClick(self)
    }
    
    
    // xcode8 xib读取（0，0，1000，1000） 的bug
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var dubTitleLabel: UILabel!
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var cycleBtn: UIButton!
    @IBOutlet weak var playProgress: UIProgressView!
    @IBOutlet weak var changceDubBtn: UIButton!
    @IBOutlet weak var changceVolumeBtn: UIButton!
 
}

// MARK: - timer 一些控制
extension DubPlayView {
    
    
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
        playProgress.progress = currentTime / totalTime
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
extension DubPlayView {
    // 播放完成
    @objc fileprivate func playbackFinished(notice: NSNotification) {
        // 恢复最开始的0状态
        audioPlayer?.currentItem?.seek(to: CMTime(value: 0, timescale: 1))

        if isCycle {
            audioPlayer?.play()
        } else {
            playBtn.isSelected = false
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if "status" == keyPath{
//            guard let status = audioPlayer?.status else {
//                return
//            }
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

    
    func playItem(url: URL) {
        deinitStatus()
        initStatus()
        audioItem = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: audioItem)
        
        audioItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackFinished(notice:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: audioItem)
        
        dubTitleLabel.text = url.lastPathComponent.components(separatedBy: ".").first
        audioTotalTime = CMTimeGetSeconds((audioPlayer?.currentItem?.asset.duration)!)
        playTimeLabel.text = TimeTool.getFormatTime(timerInval: audioTotalTime)
 
    }
    
    
}
