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
    func playBtnClick(_ dubPlayView: DubPlayView, playBtn: UIButton)
    func changceDubClick(_ dubPlayView: DubPlayView)
}

class DubPlayView: UIView {
    
    weak var delegate: DubPlayViewDelegate?
    //申明一个媒体播放控件
    var audioPlayer: MBAAudioPlayer?
    
    var timer: Timer?
    var audioTotalTime: TimeInterval!
    
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var dubTitleLabel: UILabel!
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var playSwitch: UIButton!
    //    @IBOutlet weak var playSwitch: Switch!
    @IBOutlet weak var changceDubBtn: UIButton!
    
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var volumeLabel: UILabel!
    
    var volume :Float? = 20{
        didSet{
            guard let volume = volume else {
                return
            }
            volumeLabel.text = Int(volume).description
            audioPlayer?.volume = volume / 100
            volumeSlider.value = volume
        }
    }
    
    var audioPower: Float {
        return audioPlayer?.audioPowerChange() ?? 0
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
        audioPlayer = nil
    }
    
    func initStatus(){
        playSwitch.isSelected = false
        volume = 20.0
    }
    
    func setUI() {
        playSwitch.adjustsImageWhenHighlighted = false
        playSwitch.addTarget(self, action: #selector(actionPlay), for: .touchUpInside)
        volumeSlider.addTarget(self, action:#selector(DubPlayView.actionVolumeSlider), for: .valueChanged)
        volumeSlider.minimumValue = 0.0
        volumeSlider.maximumValue = 100.0
        volumeSlider.setThumbImage(#imageLiteral(resourceName: "record_dub_volumecircle_ico"), for: .normal)
        changceDubBtn.addTarget(self, action: #selector(DubPlayView.actionChangceDub), for: .touchUpInside)
        timerInit()
        initStatus()
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 10, height: 10)
        layer.cornerRadius = 5
        layer.borderColor = UIColor.colorWithHexString("f1f8ff").cgColor
        layer.borderWidth = 1
        
    }
    
    func actionVolumeSlider(sender: UISlider) {
        volume = sender.value
    }
    
    func actionPlay(btn: UIButton) {
        if (audioPlayer?.isPlaying)! { // 在播放，点击后暂停
            playPause()
            playSwitch.isSelected = false
        } else {
            audioPlayer?.continuePlay()
            playSwitch.isSelected = true
            timerContinue()
        }
        delegate?.playBtnClick(self, playBtn: btn)
    }
    
    func playPause() {
        playSwitch.isSelected = false
        audioPlayer?.pausePlay()
        timerPause()
    }

    func actionChangceDub(sender: UIButton) {
        delegate?.changceDubClick(self)
    }
    
    
    // xcode8 xib读取（0，0，1000，1000） 的bug
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    

    
//    @IBOutlet weak var playBtn: UIButton!
//    @IBOutlet weak var cycleBtn: UIButton!
//    @IBOutlet weak var playProgress: UIProgressView!
//    @IBOutlet weak var changceDubBtn: UIButton!
//    @IBOutlet weak var changceVolumeBtn: UIButton!
 
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
        let remainTime = (audioPlayer?.duration)! - (audioPlayer?.currentTime)!
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

    func playItem(url: URL) {
        audioPlayer = MBAAudioPlayer(contentsOf: url)
        audioPlayer?.numberOfLoops = -1
        dubTitleLabel.text = url.lastPathComponent.components(separatedBy: ".").first
        playTimeLabel.text = TimeTool.getFormatTime(timerInval: (audioPlayer?.duration ?? 0))
        audioPlayer?.volume = volume! / 100
        playSwitch.isSelected = false
    }

}
