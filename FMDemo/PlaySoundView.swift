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
        
        playSlider.setThumbImage(nil, for: .normal)
        
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
    
    var isPlay: Bool = false
    var isPay: Bool = false
    
    func tapAction(_ sender: UITapGestureRecognizer) {
        delegate?.playSoundViewClick(self)
        
    }
    
    /// 已付款点击播放状态
    func setLinstenClick() {
        
        if audioPlayer != nil && audioItem != nil{
            (self.audioPlayer?.rate == 1) ? self.setPauseStatus() : self.setPlayStatus() // 由速度判断是否播放
            return
        }
        let playString = "http://i.111ttt.com:8282/97301815582.mp3"

        self.onSetAudio(playString)
        (self.audioPlayer?.rate == 1) ? self.setPauseStatus() : self.setPlayStatus() // 由速度判断是否播放
        
    }


    /// 正在播放状态
    func setPlayStatus() {
        audioPlayer?.play()

    }
    
    

    /// 暂停播放状态
    func setPauseStatus() {

        playTimeLabel.isHidden = false
        audioPlayer?.pause()
        audioPlayer?.seek(to: CMTime(seconds: 0, preferredTimescale: 1000))
    }
 
}


// MARK: - 音频播放状态设置
extension PlaySoundView {
    
    func onSetAudio(_ url:String, isCache:Bool = false){
    
        var itemUrl:URL?
        if isCache {
            itemUrl = URL(fileURLWithPath: url)
        } else {
            itemUrl = URL(string: url)
        }
        guard let itemOkUrl = itemUrl else {
            print("url 不能为空")
            return
        }
        audioItem = AVPlayerItem(url: itemOkUrl)
        audioPlayer = AVPlayer(playerItem: audioItem)
        
        audioItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackFinished(notice:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: audioItem)
        
    }
    
    // 播放完成
    @objc fileprivate func playbackFinished(notice: NSNotification) {
        // 恢复最开始的0状态
        audioPlayer?.currentItem?.seek(to: CMTime(value: 0, timescale: 1))
    }
    
    
}
