//
//  RecordViewController.swift
//  FMDemo
//
//  Created by mba on 17/1/24.
//  Copyright © 2017年 mbalib. All rights reserved.
//
import UIKit
import AVFoundation

class RecordViewController: UIViewController {
    
    
    var barWaveView: BarWaveView = {
        let cgRect = CGRect(x: 0, y: 66, width: UIScreen.main.bounds.width, height: 80.0)
        let barWaveView = BarWaveView(frame: cgRect)
        return barWaveView
    }()
    
    var pointArray = [CGFloat]()
    
    @IBOutlet weak var timeLabel: UILabel!
    /// 配音的容器
    @IBOutlet weak var dubView: UIView!
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var listenPlayBtn: UIButton!
    @IBOutlet weak var reRecordBtn: UIButton!
    @IBOutlet weak var cutBtn: UIButton!
    @IBOutlet weak var savaBtn: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    let seletctDubVC = SeletceDubViewController()
    let dubPlayView = DubPlayView.dubPlayView()
    var addDubBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("添加配音", for: .normal)
        btn.setTitleColor(UIColor.lightGray, for: .normal)
        btn.sizeToFit()
        btn.addTarget(self, action: #selector(RecordViewController.actionAddDub), for: .touchUpInside)
        return btn
    }()
    
    var timer: Timer?
    var time:TimeInterval = 0
    var isCuted: Bool = false
    
    /// 跳到 播放或裁剪 的url
    var voiceURL: URL?
    
    
    // 获取录音频率的计时器
    var recordMetersTimer: Timer?
    var recordMetersTime: TimeInterval = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addDubBtn.frame = dubView.bounds
    }
}

extension RecordViewController {
    func setup() {
        recordBtn.addTarget(self, action: #selector(actionRecordClick), for: .touchUpInside)
        listenPlayBtn.addTarget(self, action: #selector(actionPlayClick), for: .touchUpInside)
        savaBtn.addTarget(self, action: #selector(actionSave), for: .touchUpInside)
        cutBtn.addTarget(self, action: #selector(actionCut), for: .touchUpInside)
        reRecordBtn.addTarget(self, action: #selector(actionReRecord), for: .touchUpInside)
        
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
        
        
        view.addSubview(barWaveView)
    }
    
    
    func initStates() {
        initStatusHide(isHidden: true)
        recordBtn.isSelected = false
        recordBtn.setTitle("开始录音", for: .normal)
        recordBtn.setTitle("录音中", for: .selected)
        
        dubPlayView.isHidden = true
        
        recordLabel.text = "点击开始录音\n最长「20分钟」哦"
        isCuted = false
        
        time = 0
        initOraginTimeStatue(time:time)
        
    }
    
    func initStatusHide(isHidden: Bool) {
        stackView.isHidden = isHidden
    }
    
    /// 初始或重置后的状态
    func resetStatus() {
        stopRecord()
        MBAAudio.audioRecorder = nil
        timerInvalidate()
        
        initStates()
        MBACache.clearCache()
    }
}

extension RecordViewController {
    
    func actionAddDub() {
        navigationController?.pushViewController(seletctDubVC, animated: true)
    }
    
    func actionRecordClick(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            MBAAudio.audioRecorder == nil ? startRecord() : continueRecord()
        }else{
            pauseRecord()
        }
    }

    
    func actionSave() {
        //        let url = isCuted ? mergeExportURL : MBAAudio.url
        //        MBAAudioUtil.changceToMp3(of: url, mp3Name: "我")
        
        let alertController = UIAlertController(title: nil, message: "给课程起个名字吧", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let okAction = UIAlertAction(title: "确定", style: .default) { (action) in
//            print(alertController.textFields?.first?.text)
        }
        alertController.addAction(okAction)
        alertController.addTextField { (textFiled) in
            textFiled.clearButtonMode = .whileEditing
        }
        present(alertController, animated: true, completion: nil)
    }
    
    /// 重新录制
    func actionReRecord() {
        let alertController = UIAlertController(title: "重新录制", message: "是否重新录制？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler:nil)
        let alertAction = UIAlertAction(title: "确定", style: .cancel, handler: { (action) in
            print("删除成功")
            self.resetStatus()
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: 点击播放
    func actionPlayClick(sender: UIButton) {
        
    }
    
    func actionCut(sender: UIButton) {

    }
}

extension RecordViewController: DubPlayViewDelegate {
    
    func changceDubClick(_ dubPlayView: DubPlayView) {
        navigationController?.pushViewController(seletctDubVC, animated: true)
    }
}

extension RecordViewController {
    //开始录音
    func startRecord() {
        initStatusHide(isHidden: false)

        MBAAudio.startRecord()
        
        timerInit()
        // 代理设为本身
        MBAAudio.audioRecorder?.delegate = self
        recordBtn.setTitle("暂停", for: .normal)
    }
    
    //继续录音
    func continueRecord() {
        if isCuted {
            MBAAudio.startRecord()
        } else {
            MBAAudio.continueRecord()
        }
        timerContinue()
    }
    
    
    //暂停录音
    func pauseRecord() {
        MBAAudio.pauseRecord()
        timerPause()
        
        dubPlayView.playPause()
        
        if isCuted { // 如果裁剪过，就合并
            
            guard let mergeExportURL = self.voiceURL,
                let recodedVoiceURL = MBAAudio.url
                else {
                    print("mergeExportURL error")
                    return
            }
            MBAAudioUtil.mergeAudio(url1: mergeExportURL, url2: recodedVoiceURL, handleComplet: { (mergeExportURL) in
                if let mergeExportURL = mergeExportURL {
//                    self.mergeExportURL = mergeExportURL
                    self.voiceURL = mergeExportURL
                }
            })
            
        } else {
            self.voiceURL = MBAAudio.url
        }
    }
    
    //停止录音
    func stopRecord() {
        MBAAudio.stopRecord()
        timerInvalidate()
    }

}


// MARK: - timer 一些控制
extension RecordViewController {
    
    func initOraginTimeStatue(time: TimeInterval){
        
        self.time = time
        timeLabel.text = TimeTool.getFormatTime(timerInval: TimeInterval(time))
    }
    
    func timerInit(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerEvent), userInfo: nil, repeats: true)
        
        recordMetersTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(recordMetersTimerEvent), userInfo: nil, repeats: true)
    }
    
    func timerPause() {
        timer?.fireDate = Date.distantFuture
        recordMetersTimer?.fireDate = Date.distantFuture
    }
    
    func timerContinue() {
        timer?.fireDate = Date()
        recordMetersTimer?.fireDate = Date()
    }
    
    func timerInvalidate(){
        timer?.invalidate()
        timer = nil
        recordMetersTimer?.invalidate()
        recordMetersTimer = nil
    }
    
    func timerEvent() { // 20分钟，1200 秒
        time = time + 1
        initOraginTimeStatue(time:time)
        if time == 1200 {
            //            结束？
        }
    }
    
    func recordMetersTimerEvent() {
        recordMetersTime = recordMetersTime + 0.2
        let recordMeters = MBAAudio.audioPowerChange()
        pointArray.insert(CGFloat(recordMeters), at: 0)
        print(pointArray.description)
        barWaveView.pointArray = pointArray
    }
    
}

// MARK: - AVAudioRecorderDelegate
extension RecordViewController: AVAudioRecorderDelegate{
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

extension RecordViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if "PlayRecordViewController" == segue.identifier {
            let playVC = segue.destination as? PlayRecordViewController
            playVC?.url = self.voiceURL
        }
    }
}

