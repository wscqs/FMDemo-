//
//  RecordViewController.swift
//  FMDemo
//
//  Created by mba on 17/1/24.
//  Copyright © 2017年 mbalib. All rights reserved.
//
import UIKit
import AVFoundation

enum RecordType{
    case onlyRecord,dub,recordAndDub
}

enum RecordVCClick{
    case no,play,reRecord,cut,save,pause
}

class RecordViewController: UIViewController {
    
    var mid: String!
    var pointXArray = [CGFloat]()
    // 录音的计时器
//    var recordTimer: Timer?
//    var time:TimeInterval = 0
    var isCuted: Bool = false
    var mergeExportURL: URL?
    
    /// 上次录音的url
    var lastRecordURL: URL?
    
    /// 跳到 播放或裁剪 的url
//    var voiceURL: URL?
    // 获取录音频率的计时器 // 0.2 也是录音的时间
    var recordMetersTimer: Timer?
    var recordMetersTime: TimeInterval = 0.0 {
        didSet{
            thumbPointXIndex = Int(recordMetersTime / 0.2)
        }
    }
    
    /// 保存点击图片
    var imgDictArray: [RecordSelectImgModel] = [RecordSelectImgModel]()
    var thumbPointXIndex: Int = 0
    
    // 获取录音强度动画的计时器
    var recordPowerTimer: Timer?
    var recordPowerTime: TimeInterval = 0.0

    /// 是否已经有录制
    var isRecorded: Bool? = false
    
    let dispatchGroup = DispatchGroup()
//    var recordVCClick = RecordVCClick.no
    
    // 顶层图片
    @IBOutlet weak var bannerImg: UIImageView!
    // 顶部状态view（包含: 音波，时间）
    @IBOutlet weak var topStatusView: UIView!
    @IBOutlet weak var topRecordPower: RecordSoundSliderView!
    @IBOutlet weak var topMusicPower: RecordSoundSliderView!
    @IBOutlet weak var timeLabel: UILabel!
    // 图片选择collectionView
    @IBOutlet weak var imgCollectionView: RecordImgCollectionView!
    /// 配音的容器
    @IBOutlet weak var dubView: UIView!
    @IBOutlet weak var addDubBtn: UIButton!
    // 底部初始状态
    @IBOutlet weak var bottomInitView: UIView!
    // 录音的操作按钮
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var listenPlayBtn: UIButton!
    @IBOutlet weak var reRecordBtn: UIButton!
    @IBOutlet weak var cutBtn: UIButton!
    @IBOutlet weak var savaBtn: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var recordTipsImg: UIImageView!
    let seletctDubVC = SeletceDubViewController()
    let dubPlayView = DubPlayView.dubPlayView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        NotificationCenter.default.addObserver(self, selector: #selector(cutComple(notification:)), name: Notification.Name(rawValue: "cutComplet"), object: nil)
        
        // 后退处理
        let backBtn: UIButton = UIButton(imageName:"nav_details_top_left", backTarget: self, action: #selector(actionNavBackBtnClick))
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        MBACache.clearRecordCache()
    }
    
    func actionNavBackBtnClick() {
        pauseRecord(recordVCClick: .no)
        if isRecorded ?? false {
            let alertController = UIAlertController(title: nil, message: "录制未保存，确定放弃吗？", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler:nil)
            let alertAction = UIAlertAction(title: "放弃录制", style: .default, handler: { (action) in
                _ = self.navigationController?.popViewController(animated: true)
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func cutComple(notification: Notification) {

        guard let cutCompleArray = notification.userInfo?["cutComplet"] as? Array<Any> else {
            return
        }
        isCuted = true
        mergeExportURL = cutCompleArray.first as? URL
        pointXArray = (cutCompleArray[1] as? [CGFloat])!
        imgDictArray = (cutCompleArray.last as? [RecordSelectImgModel])!
        recordMetersTime = Double(pointXArray.count) * 0.2
        initOraginTimeStatue(time: recordMetersTime)
        lastRecordURL = MBAAudio.url
    }
    

    
    
    // MARK: - StroyBoard action
    @IBAction func actionStartRecord(_ sender: UIButton) {
        if !canRecord() {
            let alertController = UIAlertController(title: "请求授权", message: "app需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克风", preferredStyle: .alert )
            let alertAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        

        isRecorded = true
        bottomInitView.isHidden = true
        topStatusView.isHidden = false
        startRecord()
    }
    
    @IBAction func actionCloseTip(_ sender: UIButton) {
        sender.isHidden = true
        recordTipsImg.isHidden = true
    }
    
    @IBAction func popRecordVC(_ sender: UIStoryboardSegue) {
    }
    
    
    @IBAction func actionOpration(_ sender: UIButton) {
        
        if 10 == sender.tag { // 试听
            pauseRecord(recordVCClick: .play)
        } else if 11 == sender.tag { // 重录
            pauseRecord(recordVCClick: .reRecord)
        } else if 12 == sender.tag { //剪切
            pauseRecord(recordVCClick: .cut)
        } else if 13 == sender.tag { //保存
            pauseRecord(recordVCClick: .save)
        }
//        else if 11 == sender.tag { // 试听
//            
//        }
        
    }
    
    
}

extension RecordViewController {
    func saveImgClick(image: UIImage,wid: String) {
        bannerImg.image = image
        let recordSelectImgModel = RecordSelectImgModel(image: image, wid: wid, thumbPointXIndex: thumbPointXIndex)
        imgDictArray.append(recordSelectImgModel)
    }
}

class RecordSelectImgModel {
    var image: UIImage
    var wid: String
    var thumbPointXIndex: Int
    var time: Int = 0
    
    init(image: UIImage, wid: String,thumbPointXIndex: Int) {
        self.image = image
        self.wid = wid
        self.thumbPointXIndex = thumbPointXIndex
        self.time = Int(Double(thumbPointXIndex) * 0.2)
    }
}

extension RecordViewController {
    func setup() {
        imgCollectionView.parentVC = self
        imgCollectionView.mid = self.mid
        addDubBtn.adjustsImageWhenHighlighted = false
        addDubBtn.addTarget(self, action: #selector(actionAddDub), for: .touchUpInside)
        recordBtn.addTarget(self, action: #selector(actionRecordClick), for: .touchUpInside)
        recordBtn.adjustsImageWhenHighlighted = false
//        listenPlayBtn.addTarget(self, action: #selector(actionPlayClick), for: .touchUpInside)
//        savaBtn.addTarget(self, action: #selector(actionSave), for: .touchUpInside)
//        cutBtn.addTarget(self, action: #selector(actionCut), for: .touchUpInside)
        reRecordBtn.addTarget(self, action: #selector(actionReRecord), for: .touchUpInside)
        
        dubPlayView.delegate = self
        dubView.addSubview(dubPlayView)
        dubPlayView.frame = dubView.bounds
        /// 选择控制器选中后回调
        seletctDubVC.selectDubURLBlock = { selectDubURL in
            self.dubPlayView.isHidden = false
            self.dubPlayView.playItem(url: selectDubURL)
        }
        
        initStates()
    }
    
    
    func initStates() {
        isRecorded = false
        pointXArray.removeAll()
        isCuted = false
        mergeExportURL = nil
        recordMetersTime = 0
        recordPowerTime = 0
        
        bannerImg.image = #imageLiteral(resourceName: "record_bannerBg")
        imgCollectionView.recordImgArray?.removeAll()
        imgCollectionView.reloadData()
        topStatusView.isHidden = true
        bottomInitView.isHidden = false
        initOraginTimeStatue(time:recordMetersTime)
        recordBtn.isSelected = false
        dubPlayView.isHidden = true
        recordLabel.text = "正在通过麦克风录制"
        
        imgDictArray.removeAll()
        thumbPointXIndex = 0
        
        MBACache.clearRecordCache()
    }
    
    
    /// 初始或重置后的状态
    func resetStatus() {
        stopRecord()
        MBAAudio.audioRecorder = nil
        timerInvalidate()
        
        initStates()
    }
}




// MARK: - action
extension RecordViewController {
    
    func actionAddDub() {
        pauseRecord()
        navigationController?.pushViewController(seletctDubVC, animated: true)
    }
    
    func actionRecordClick(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected { // 选中为暂停
            pauseRecord(recordVCClick: .pause)
        }else{ // 不选中 录音
            continueRecord()
        }
    }

    
    func actionSave() {
        let url = mergeExportURL
        let alertController = UIAlertController(title: "是否保存章节录音", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        let okAction = UIAlertAction(title: "确定", style: .default) { (action) in
            var wareArray = [[String: Any]]()
            for recordSelectImgModel in self.imgDictArray {
                var dict: [String: Any] = ["time": recordSelectImgModel.time]
                dict["wid"] = recordSelectImgModel.wid
                wareArray.append(dict)
            }            
            MBAProgressHUD.show()
            var mp3url: URL?
            let disItem = DispatchWorkItem(block: { 
                mp3url = MBAAudioUtil.changceToMp3(of: url, mp3Name: Date().formatDate)
            })
            let queueToMP3 = DispatchQueue(label: "queueToMP3")
            queueToMP3.async(group: self.dispatchGroup, execute: disItem)
            
            self.dispatchGroup.notify(queue: .main, execute: {

                guard let saveURL = mp3url else {
                    MBAProgressHUD.showErrorWithStatus("上传失败，请重试")
                    return
                }
                let mp3Data = try? Data(contentsOf: saveURL)

                KeService.actionRecordAudio(mid: self.mid, file: mp3Data!, time: String(self.recordMetersTime),ware: wareArray, success: { (bean) in
                    MBAProgressHUD.dismiss()
                    for vc in (self.navigationController?.viewControllers)! {
                        if vc is CourceMainViewController {
                            let courseMainVC = vc as? CourceMainViewController
                            courseMainVC?.mainTb.dataList = nil
                            _ = self.navigationController?.popToViewController(vc, animated: true)
                            break
                        }
                    }
                }, failure: { (error) in
                    MBAProgressHUD.dismiss()
                    MBAProgressHUD.showErrorWithStatus("上传失败，请重试")
                })
            })
        }

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    
    /// 重新录制
    func actionReRecord() {
        pauseRecord()
        let alertController = UIAlertController(title: nil, message: "确定要重录吗？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler:nil)
        let alertAction = UIAlertAction(title: "确定", style: .default, handler: { (action) in
            print("删除成功")
            self.resetStatus()
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension RecordViewController {
    //开始录音
    func startRecord() {
        MBAAudio.startRecord()
        timerInit()
        // 代理设为本身
        MBAAudio.audioRecorder?.delegate = self
        recordBtnShow(isRecord: true)
    }
    
    //继续录音
    func continueRecord() {
        if isCuted {
            MBAAudio.startRecord()
        } else {
            MBAAudio.continueRecord()
        }
        timerContinue()
        recordBtnShow(isRecord: true)
    }
    
    func recordBtnShow(isRecord: Bool) {
        if isRecord {
            recordLabel.text = "正在通过麦克风录制"
            recordBtn.isSelected = false
        } else {
            recordLabel.text = "暂停麦克风录制"
            recordBtn.isSelected = true
        }
    }
    
    
    //暂停录音
    func pauseRecord(recordVCClick: RecordVCClick? = .no) {

        recordBtnShow(isRecord: false)

        MBAAudio.pauseRecord()
        timerPause()
        
        dubPlayView.playPause()
        
        if isCuted { // 如果裁剪过，就合并
            if lastRecordURL == MBAAudio.url { // 剪切后未开始重新录
                self.pushToClick(recordVCClick: recordVCClick!)
                return
            }
            lastRecordURL = MBAAudio.url
            guard let mergeExportURL = self.mergeExportURL,
                let recodedVoiceURL = MBAAudio.url
                else {
                    print("mergeExportURL error")
                    return
            }
            if !(recordVCClick == .no){
                MBAProgressHUD.show()
            }
            
            MBAAudioUtil.mergeAudio(url1: mergeExportURL, url2: recodedVoiceURL, handleComplet: { (mergeExportURL) in
                if let mergeExportURL = mergeExportURL {
                    self.mergeExportURL = mergeExportURL
                    MBAProgressHUD.dismiss()
                    self.pushToClick(recordVCClick: recordVCClick!)
                } else {
                    MBAProgressHUD.showErrorWithStatus("出错")
                }
            })
        } else {
            self.mergeExportURL = MBAAudio.url
            self.pushToClick(recordVCClick: recordVCClick!)
        }
    }
    
    func pushToClick(recordVCClick: RecordVCClick) {

        self.recordMetersTime = MBAAudioPlayer(contentsOf: self.mergeExportURL!).duration
        let lower = Int(self.recordMetersTime / 0.2)
        if lower < self.pointXArray.count {
            self.pointXArray.removeSubrange(Range(uncheckedBounds: (lower: lower, upper: self.pointXArray.count)))
        }
        
        switch recordVCClick {
        case .play:
            self.performSegue(withIdentifier: "PlayRecordViewController", sender: self)
        case .cut:
            self.performSegue(withIdentifier: "CutRecordViewController", sender: self)
        case .save:
            actionSave()
        case .reRecord:
            actionReRecord()
        default:
            break
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
        
//        self.time = time
        timeLabel.text = TimeTool.getFormatTime(timerInval: TimeInterval(time))
    }
    
    func timerInit(){
        recordMetersTimer = Timer.scheduledTimer(timeInterval: TimeInterval(kWaveTime), target: self, selector: #selector(recordMetersTimerEvent), userInfo: nil, repeats: true)
        RunLoop.current.add(recordMetersTimer!, forMode: .commonModes)
        recordPowerTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.001), target: self, selector: #selector(updatePower), userInfo: nil, repeats: true)
    }
    
    func timerPause() {
//        recordTimer?.fireDate = Date.distantFuture
        recordMetersTimer?.fireDate = Date.distantFuture
        recordPowerTimer?.fireDate = Date.distantFuture
    }
    
    func timerContinue() {
//        recordTimer?.fireDate = Date()
        recordMetersTimer?.fireDate = Date()
        recordPowerTimer?.fireDate = Date()
    }
    
    func timerInvalidate(){
//        recordTimer?.invalidate()
//        recordTimer = nil
        recordMetersTimer?.invalidate()
        recordMetersTimer = nil
        recordPowerTimer?.invalidate()
        recordPowerTimer = nil
    }
    
    func recordTimerEvent() { // 20分钟，1200 秒
//        time = time + 1
//        initOraginTimeStatue(time:time)
//        if time == 1200 {
//            //            结束？
//        }
    }
    
    func recordMetersTimerEvent() {
        recordMetersTime = recordMetersTime + kWaveTime
        initOraginTimeStatue(time: recordMetersTime)
        
        pointXArray.append(CGFloat(MBAAudio.audioPowerChange()))
    }
    
    func updatePower() {
        topRecordPower.setValue(1 - MBAAudio.audioPowerChange(), animated: true)
        topMusicPower.setValue(1 - dubPlayView.audioPower, animated: true)
    }
}

extension RecordViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if "PlayRecordViewController" == segue.identifier {
            let playVC = segue.destination as? PlayRecordViewController
            playVC?.url = self.mergeExportURL
            playVC?.pointXArray = self.pointXArray
            playVC?.imgDictArray = self.imgDictArray
            playVC?.mid = self.mid
        }else if "CutRecordViewController" == segue.identifier {
            let playVC = segue.destination as? CutRecordViewController
            playVC?.url = self.mergeExportURL
            playVC?.pointXArray = self.pointXArray
            playVC?.imgDictArray = self.imgDictArray
        }
        
    }
}

// MARK: - AVAudioRecorderDelegate
extension RecordViewController: AVAudioRecorderDelegate{
    /// 是否可录音控制
    func canRecord() -> Bool{
        var bCanRecord = true
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.requestRecordPermission { (granted) in
            bCanRecord = granted
        }
        return bCanRecord
    }
    
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

extension RecordViewController: DubPlayViewDelegate {    
    func changceDubClick(_ dubPlayView: DubPlayView) {
        pauseRecord()
        let sheetVc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let canAction = UIAlertAction(title: "关闭", style: .cancel, handler: nil)
        let changceAction = UIAlertAction(title: "更换配乐", style: .destructive) { (action) in
            self.navigationController?.pushViewController(self.seletctDubVC, animated: true)
        }
        let removeAction = UIAlertAction(title: "移除配乐", style: .default) { (action) in
            self.dubPlayView.playPause()
            self.dubPlayView.isHidden = true
        }
        sheetVc.addAction(canAction)
        sheetVc.addAction(changceAction)
        sheetVc.addAction(removeAction)        
        navigationController?.present(sheetVc, animated: true, completion: nil)
    }
    
    func playBtnClick(_ dubPlayView: DubPlayView, playBtn: UIButton) {
//        if playBtn.isSelected {
//            timerContinue()
//            recordType = .dub
//        } else {
//            timerPause()
//        }
    }
}

