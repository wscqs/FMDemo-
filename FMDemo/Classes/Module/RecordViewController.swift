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
        btn.addTarget(self, action: #selector(ViewController.actionAddDub), for: .touchUpInside)
        return btn
    }()
    
    var timer: Timer?
    var time:TimeInterval = 0
    
    var mergeExportURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

extension RecordViewController {
    func setup() {
        recordBtn.addTarget(self, action: #selector(actionRecordClick), for: .touchUpInside)
        listenPlayBtn.addTarget(self, action: #selector(actionPlayClick), for: .touchUpInside)
        savaBtn.addTarget(self, action: #selector(actionSave), for: .touchUpInside)
        cutBtn.addTarget(self, action: #selector(actionCut), for: .touchUpInside)
        
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
    }
    
    
    func initStates() {
        initStatusHide(isHidden: true)
        recordBtn.isSelected = false
        recordBtn.setTitle("开始录音", for: .normal)
        recordBtn.setTitle("录音中", for: .selected)
        
        dubPlayView.isHidden = true
        
        recordLabel.text = "点击开始录音\n最长「20分钟」哦"
    }
    
    func initStatusHide(isHidden: Bool) {
        stackView.isHidden = isHidden
    }
}

extension RecordViewController {
    func actionRecordClick(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            MBAAudio.audioRecorder == nil ? startRecord() : continueRecord()
        }else{
            pauseRecord()
        }
    }
    //MARK: 点击播放
    func actionPlayClick(sender: UIButton) {

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

        MBAAudio.initRecord()
        MBAAudio.startRecord()
        timerInit()
        // 代理设为本身
        MBAAudio.audioRecorder?.delegate = self
        recordBtn.setTitle("暂停", for: .normal)
    }
    
    //继续录音
    func continueRecord() {
        MBAAudio.stopRecord()
        MBAAudio.initRecord()
        MBAAudio.startRecord()
        timerContinue()
    }
    
    
    //暂停录音
    func pauseRecord() {
        MBAAudio.pauseRecord()
        timerPause()
        
        dubPlayView.playPause()
        
        guard let mergeExportURL = mergeExportURL,
            let recodedVoiceURL = MBAAudio.url
            else {
                print("mergeExportURL error")
                return
        }
        MBAAudioUtil.mergeAudio(url1: mergeExportURL, url2: recodedVoiceURL, handleComplet: { (mergeExportURL) in
            if let mergeExportURL = mergeExportURL {
                self.mergeExportURL = mergeExportURL
//                self.loadPlay(url: mergeExportURL)
            }
        })
        
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

