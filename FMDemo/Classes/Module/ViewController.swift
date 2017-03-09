//
//  ViewController.swift
//  FMDemo
//
//  Created by mba on 16/11/30.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var listenPlayBtn: UIButton!
    @IBOutlet weak var cutBtn: UIButton!
    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var reRecordBtn: UIButton!
    @IBOutlet weak var savaBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var cutSlider: UISlider!
    @IBOutlet weak var cutCancelBtn: UIButton!
    @IBOutlet weak var cutYesBtn: UIButton!
    
    /// 配音的容器
    @IBOutlet weak var dubView: UIView!
    
    
    
    let seletctDubVC = SeletceDubViewController()
    let dubPlayView = DubPlayView.dubPlayView()
    
    var addDubBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("添加配音", for: .normal)
        btn.setTitleColor(UIColor.lightGray, for: .normal)
        btn.sizeToFit()
        btn.addTarget(self, action: #selector(ViewController.actionAddDub), for: .touchUpInside)
        return btn
    }()
    
    
    
    var isCuted: Bool = false
    
    var timer: Timer?
    var time:TimeInterval = 0
    
    
    var playTimer: Timer?
    var playTime:TimeInterval = 0
    
    
    var sliderTime: TimeInterval = 0
    var sliderTimer: Timer?
    var tipTimer: Timer?
    var player: MBAAudioPlayer!
    

    var cutExportURL: URL?
    var mergeExportURL: URL?
    

    override func viewDidLoad() {
        super.viewDidLoad()
            
//        view.addSubview(addBtn)
//        addBtn.setTitle("合并", for: .normal)
//        addBtn.setTitleColor(UIColor.blue, for: .normal)
//        addBtn.center = view.center
//        addBtn.sizeToFit()
//        addBtn.addTarget(self, action: "trans", for: .touchUpInside)
                
        
        recordBtn.addTarget(self, action: #selector(actionRecordClick), for: .touchUpInside)

        listenPlayBtn.addTarget(self, action: #selector(actionPlayClick), for: .touchUpInside)
  
        savaBtn.addTarget(self, action: #selector(actionSave), for: .touchUpInside)
        cutBtn.addTarget(self, action: #selector(actionCut), for: .touchUpInside)
        
        reRecordBtn.addTarget(self, action: #selector(actionReRecord), for: .touchUpInside)
        
        slider.addTarget(self, action: #selector(actionSlider), for: .valueChanged)

        slider.isContinuous = false // 滑动结束 才会执行valueChanged 事件
        

        cutSlider.isContinuous = false
        cutSlider.addTarget(self, action: #selector(actionCutSlider), for: .valueChanged)
        
        cutCancelBtn.addTarget(self, action: #selector(actionStrokeCancel), for: .touchUpInside)
        cutYesBtn.addTarget(self, action: #selector(actionStrokeYes), for: .touchUpInside)
        
        dubView.addSubview(addDubBtn)
        dubPlayView.delegate = self
        dubView.addSubview(dubPlayView)
        dubPlayView.frame = dubView.bounds
        dubPlayView.isHidden = true
        /// 选择控制器选中后回调
        seletctDubVC.selectDubURLBlock = { selectDubURL in
            self.dubPlayView.isHidden = false
            self.dubPlayView.playItem(url: selectDubURL)
        }
        
        initStates()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !canRecord() {
            let alertController = UIAlertController(title: "请求授权", message: "app需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克风", preferredStyle: .alert )
            let alertAction = UIAlertAction(title: "确定", style: .default, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addDubBtn.frame = dubView.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        
    }
    
    func initStates() {
        initStatusHide(isHidden: true)
        recordBtn.isSelected = false
        recordBtn.setTitle("开始录音", for: .normal)
        recordBtn.setTitle("录音中", for: .selected)
        cutSlider.value = 0
        initOraginTimeStatue(time:0)
        isCuted = false
        
        dubPlayView.isHidden = true
        
        recordLabel.text = "点击开始录音\n最长「20分钟」哦"
        
    }
    
    
    func actionAddDub() {
        navigationController?.pushViewController(seletctDubVC, animated: true)
    }
    
    func actionSave() {
//        let url = isCuted ? mergeExportURL : MBAAudio.url
//        MBAAudioUtil.changceToMp3(of: url, mp3Name: "我")
        
        let alertController = UIAlertController(title: nil, message: "给课程起个名字吧", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let okAction = UIAlertAction(title: "确定", style: .default) { (action) in
            print(alertController.textFields?.first?.text ?? "")
        }
        alertController.addAction(okAction)
        alertController.addTextField { (textFiled) in
            textFiled.clearButtonMode = .whileEditing
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func actionRecordClick(sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            MBAAudio.audioRecorder == nil ? startRecord() : continueRecord()
        }else{
            pauseRecord()
        }
    }
    
    /// 初始或重置后的状态
    func resetStatus() {
        
        stopRecord()
        stopPlay()
        player = nil
        MBAAudio.audioRecorder = nil
        stopTimer()
        initStates()
        
        MBACache.clearCache()
    }

    
    func actionStrokeCancel() {
        cutHide(isHidden: true)
    }
    
    func actionStrokeYes() {
        cutHide(isHidden: true)
        cutEvent()
    }
    

    
    
    
    //开始录音
    func startRecord() {
        recoredHide(isHidden: true)
        recordStatus(isPause: false)
        
        MBAAudio.initRecord()
        MBAAudio.startRecord()
        timerInit()
        // 代理设为本身
        MBAAudio.audioRecorder?.delegate = self
        recordBtn.setTitle("暂停", for: .normal)
    }
    

    /// 重录按钮与暂停按钮变化
    func recordStatus(isPause:Bool) {

        recordStatusBtn(isEnabel: isPause)
        if isPause { // 暂停状态下，  右边显示重置
            reRecordBtn.setTitle("重置", for: .normal)
            reRecordBtn.removeTarget(self, action: #selector(ViewController.reRecordWithPause), for: .touchUpInside)
            reRecordBtn.addTarget(self, action: #selector(ViewController.actionReRecord), for: .touchUpInside)
            recordLabel.text = "点击继续录制"
        } else {
            reRecordBtn.setTitle("暂停", for: .normal)
            reRecordBtn.removeTarget(self, action: #selector(ViewController.actionReRecord), for: .touchUpInside)
            reRecordBtn.addTarget(self, action: #selector(ViewController.reRecordWithPause), for: .touchUpInside)
            recordLabel.text = "麦克风已启动"
        }
    }
    
    
    func reRecordWithPause() {
        actionRecordClick(sender: recordBtn)
    }
    
    //暂停录音
    func pauseRecord() {
        recordStatus(isPause: true)
        recoredHide(isHidden: false)
        
        MBAAudio.pauseRecord()
        timerPause()
        
        dubPlayView.playPause()
        
        if isCuted { // 如果裁剪过，就合并

            guard let mergeExportURL = mergeExportURL,
                let recodedVoiceURL = MBAAudio.url
                 else {
                    print("mergeExportURL error")
                    return
            }
            MBAAudioUtil.mergeAudio(url1: mergeExportURL, url2: recodedVoiceURL, handleComplet: { (mergeExportURL) in
                if let mergeExportURL = mergeExportURL {
                    self.mergeExportURL = mergeExportURL
                    self.loadPlay(url: mergeExportURL)
                }
            })
            
        } else {
            loadPlay(url: MBAAudio.url)
        }
        
    }
    
    //继续录音
    func continueRecord() {
        recordStatus(isPause: false)
        recoredHide(isHidden: true)
        
        if isCuted {
            MBAAudio.stopRecord()
            MBAAudio.initRecord()
            MBAAudio.startRecord()
        } else {
            MBAAudio.continueRecord()
        }
       

        time = player.duration
        initOraginTimeStatue(time: time)
        timerContinue()
        
        stopPlay()
        
    }
    
    //停止录音
    func stopRecord() {
        MBAAudio.stopRecord()
        timerInvalidate()
    }
    
  
    /// 重新录制
    func actionReRecord() {
        let alertController = UIAlertController(title: "重新录制", message: "是否重新录制？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler:nil)
        let alertAction = UIAlertAction(title: "确定", style: .cancel, handler: { (action) in
            self.resetStatus()
        })

        alertController.addAction(cancelAction)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }

    /// 是否可录音控制
    func canRecord() -> Bool{
        var bCanRecord = true
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.requestRecordPermission { (granted) in
            bCanRecord = granted
        }
        return bCanRecord
    }

}



extension ViewController: DubPlayViewDelegate {
    
    func playBtnClick(_ dubPlayView: DubPlayView, playBtn: UIButton) {
        
    }
    func changceDubClick(_ dubPlayView: DubPlayView) {
        actionAddDub()
    }
}

// MARK: - 隐藏与按钮 状态
extension ViewController {
    /// 初始化的隐藏
    func initStatusHide(isHidden: Bool) {
        recoredHide(isHidden: true)
        cutHide(isHidden: true)
        recoredHide(isHidden: true)
        noRecordHide(isHidden: true)
    }
    
    /// 截取的隐藏
    func cutHide(isHidden: Bool) {
        cutCancelBtn.isHidden = isHidden
        cutYesBtn.isHidden = isHidden
        cutSlider.isHidden = isHidden
        cutBtn.isSelected = !isHidden
    }
    
    /// 录音的隐藏
    func recoredHide(isHidden: Bool) {
        listenPlayBtn.isHidden = isHidden
        cutBtn.isHidden = isHidden
        slider.isHidden = isHidden
        cutHide(isHidden: true)
        noRecordHide(isHidden: false)
    }
    
    /// 未录音时隐藏
    func noRecordHide(isHidden: Bool) {
        reRecordBtn.isHidden = isHidden
        savaBtn.isHidden = isHidden
    }
    
    /// 播放状态 其余按钮是否能用
    func playStatusBtn(isEnabel: Bool) {
        cutBtn.isEnabled = isEnabel
        recordBtn.isEnabled = isEnabel
        reRecordBtn.isEnabled = isEnabel
        savaBtn.isEnabled = isEnabel
    }
    
    /// 录音状态 其余按钮是否能用
    func recordStatusBtn(isEnabel: Bool) {
//        cutBtn.isEnabled = isEnabel
//        recordBtn.isEnabled = isEnabel
//        reRecordBtn.isEnabled = isEnabel
        savaBtn.isEnabled = isEnabel
    }
    
}

extension ViewController {
    
    func cutEvent() {
        // 1.拿到预处理音频文件
        
        guard let url = isCuted ? mergeExportURL : MBAAudio.url else{return}
        
        let startCutTime = 0.0
        let stopCutTime = Double(cutSlider.value)
        MBAAudioUtil.cutAudio(of: url, startTime: startCutTime, stopTime: stopCutTime) { (cutExportURL) in
            if let cutExportURL = cutExportURL {
                self.isCuted = true
                self.mergeExportURL = cutExportURL
                self.loadPlay(url: cutExportURL)
            } else {
                print("剪切失败")
            }
        }
    }
}



// MARK: - timer 一些控制
extension ViewController {
    
    func initOraginTimeStatue(time: TimeInterval){
        self.time = time
        timeLabel.text = TimeInterval(time).getFormatTime()
    }
    
    func timerInit(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(actionTimer), userInfo: nil, repeats: true)
    }
    
    func timerInvalidate(){
        timer?.invalidate()
        timer = nil
    }
    
    func actionTimer() { // 20分钟，1200 秒
        time = time + 1
        initOraginTimeStatue(time:time)
        if time == 1200 {
//            结束？
        }
    }

    
    func timerPause() {
        timer?.fireDate = Date.distantFuture
    }
    
    func timerContinue() {
        timer?.fireDate = Date()
    }

}


// MARK: - AVAudioRecorderDelegate
extension ViewController: AVAudioRecorderDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("录音完成")
        }else{
            print("录音失败")
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if error != nil {
//            print(error)
        }
    }
    
}





// MARK: - PlayViewController  后修改

extension ViewController  {
    func loadPlay(url: URL?) {
        guard let url = url else {
            return
        }
        player = MBAAudioPlayer(contentsOf: url)
        player.player?.delegate = self
        initCutUI()
        
//        slider.url = url
    }
    
    func initCutUI() {
        slider.minimumValue = 0
        slider.maximumValue = Float(player.duration)
        slider.value = 0
        cutSlider.minimumValue = 0
        cutSlider.maximumValue = Float(player.duration)
        cutSlider.value = 0
        cutSlider.isContinuous = false
        updateLabel()
    }
}
extension ViewController {
    func actionCutCancel() {
        cutBtn.isSelected = false
        cutHide(isHidden: true)
    }
    
    func actionCutYes() {
        cutBtn.isSelected = false
        cutHide(isHidden: true)
        
        cutEvent()
    }
    
    func actionSlider(sender: UISlider) {
        pausePlay()
        player.currentTime = TimeInterval(sender.value)
        sliderTime = player.currentTime
        updateLabel()
        if listenPlayBtn.isSelected {// 在播放中
            continuePlay()
        } else {
            
        }
        
    }
    
    func actionCut(sender: UIButton) {
        pausePlay()
        sender.isSelected = !sender.isSelected
        if sender.isSelected { // 裁剪中
            cutHide(isHidden: false)
        } else {
            cutHide(isHidden: true)
        }        
    }
    
    func actionCutSlider(sender: UISlider) {
        slider.value = sender.value
        actionSlider(sender: sender)
    }
    
    //MARK: 点击播放
    func actionPlayClick(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected { // 播放状态
            
            if cutBtn.isSelected { // 裁剪中
                if player.currentTime == 0 {
                    actionCutSlider(sender: cutSlider)
                }else{
                    continuePlay()
                }
            }else {
                print(player.currentTime)
                player.currentTime == 0 ? startPlay() : continuePlay()
            }
            
        } else {
            pausePlay()
        }
    }

}

extension ViewController {
    func startPlay() {
        playStatusBtn(isEnabel: false)
        playTime = 0
        sliderTime = 0
        player?.currentTime = playTime
        updateLabel()
        player?.startPlay()
        
        initTimer()
    }
    
    func pausePlay() {
        playStatusBtn(isEnabel: true)
        player?.pausePlay()
        pauseTimer()
    }
    
    func continuePlay() {
        playStatusBtn(isEnabel: false)
        player?.continuePlay()
        continueTimer()
    }
    
    func stopPlay() {
        pauseTimer()
        listenPlayBtn.isSelected = false
        playStatusBtn(isEnabel: true)
        if cutBtn.isSelected {
            let playTime = Double(cutSlider.value).getFormatTime()
            let endTime = player.duration.getFormatTime()
            timeLabel.text = "\(playTime)\\\(endTime)"
        }
    }
}
extension ViewController {
    func tipTimerEvent() {
        updateLabel()
    }
    
    func sliderTimerEvent() {
        sliderTime = sliderTime + 0.01
        slider.value = Float(sliderTime)
        if sliderTime >= player.duration {
            stopPlay()
        }
    }
    
    
    func updateLabel() {
        let playTime = (player.currentTime + 0.2).getFormatTime()//player.currentTime  第一秒0.9几
        let endTime = player.duration.getFormatTime()
        timeLabel.text = "\(playTime)\\\(endTime)"
    }

}
extension ViewController {
    func initTimer() {
        tipTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(tipTimerEvent), userInfo: nil, repeats: true)
        sliderTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(sliderTimerEvent), userInfo: nil, repeats: true)
    }
    
    func pauseTimer() {
        tipTimer?.fireDate = Date.distantFuture
        sliderTimer?.fireDate = Date.distantFuture
    }
    
    func continueTimer() {
        tipTimer?.fireDate = Date()
        sliderTimer?.fireDate = Date()
    }
    
    func stopTimer() {
        sliderTimer?.invalidate()
        sliderTimer = nil
        tipTimer?.invalidate()
        tipTimer = nil
        
        timerInvalidate()
    }
}

extension ViewController: AVAudioPlayerDelegate{

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("finishS")
            tipTimer?.fireDate = Date.distantFuture
        } else {
            print("finishError")
        }
    }
}
