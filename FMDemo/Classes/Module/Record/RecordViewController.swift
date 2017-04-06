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

    fileprivate var isCuted: Bool = false
    var mergeExportURL: URL?
    
    /// 上次录音的url
    var lastRecordURL: URL?

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

    // MARK: - LeftRycel
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        // 剪切与app竟然后台通知
        NotificationCenter.default.addObserver(self, selector: #selector(cutComple(notification:)), name: Notification.Name(rawValue: "cutComplet"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: NSNotification.Name.LifeCycle.WillResignActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChangeListenerCallback), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
        
        // 后退处理
        let backBtn: UIButton = UIButton(imageName:"nav_details_top_left", backTarget: self, action: #selector(actionNavBackBtnClick))
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !canRecord() {
            let alertController = UIAlertController(title: "无法录音", message: "请允许“智库课堂”访问麦克风", preferredStyle: .alert )
            let alertAction = UIAlertAction(title: "立即允许", style: .default, handler: { (action) in
                let url = URL(string: UIApplicationOpenSettingsURLString)
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.openURL(url!)
                }
            })
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
        }
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
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func audioRouteChangeListenerCallback(notification: Notification) {
//        NSDictionary *interuptionDict = notification.userInfo;
//        NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
//        switch (routeChangeReason) {
//        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
//            NSLog(@"AVAudioSessionRouteChangeReasonNewDeviceAvailable");
//            tipWithMessage(@"耳机插入");
//            break;
//        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
//            NSLog(@"AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
//            tipWithMessage(@"耳机拔出，停止播放操作");
//            break;
//        case AVAudioSessionRouteChangeReasonCategoryChange:
//            // called at start - also when other audio wants to play
//            tipWithMessage(@"AVAudioSessionRouteChangeReasonCategoryChange");
//            break;
//        }
        
//        let interuptionDict = notification.userInfo
//        let routeChangeReason = interuptionDict?[AVAudioSessionRouteChangeReasonKey] as! NSInteger
//        switch routeChangeReason {
//        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
//        }
        
//        NSArray* inputArray = [[AVAudioSession sharedInstance] availableInputs];
//        for (AVAudioSessionPortDescription* desc in inputArray) {
//            if ([desc.portType isEqualToString:AVAudioSessionPortBuiltInMic]) {
//                NSError* error;
//                [[AVAudioSession sharedInstance] setPreferredInput:desc error:&error];
//            }
//        }
        
//        [<AVAudioSessionPortDescription: 0x174016f50, type = MicrophoneBuiltIn; name = iPhone 麦克风; UID = Built-In Microphone; selectedDataSource = 下>, <AVAudioSessionPortDescription: 0x174016a30, type = MicrophoneWired; name = 耳机麦克风; UID = Wired Microphone; selectedDataSource = (null)>]
        
        let inputArray = AVAudioSession.sharedInstance().availableInputs
//        try? AVAudioSession.sharedInstance().setPreferredInput(inputArray?.first!)
//        try? AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
//        print(notification.userInfo.debugDescription)
//        print(inputArray.debugDescription)
        
        if (inputArray?.count ?? 1) == 1 {
            try? AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        }
        
//        for desc in inputArray! {
//            print(desc.portType.debugDescription)
//            if desc.portType != AVAudioSessionPortHeadphones { // 耳机
////                try? AVAudioSession.sharedInstance().setPreferredInput(desc)
//                
////                try? AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.none)
//                break
//            }
//        }
    }
    
    /// 应用程序进入后台
    func willResignActive () {
        pauseRecord(recordVCClick: .no)
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

    }
    
    
}

// MARK: - init
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
            let dispatchGroup = DispatchGroup()
            let queueToMP3 = DispatchQueue(label: "queueToMP3")
            queueToMP3.async(group: dispatchGroup, execute: disItem)            
            dispatchGroup.notify(queue: .main, execute: {

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
//        MBAAudio.audioRecorder?.delegate = self
        recordBtnShow(isRecord: true)
        
        sessionCategory(isRecord: true)
    }
    
    /// session状态
    ///
    /// - Parameter isRecord: 录音状态，默认true，   false 则设置为播放状态
    func sessionCategory(isRecord: Bool? = true) {
        if isRecord ?? true {
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
        } else {
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        }
    }
    
    //继续录音
    func continueRecord() {
        
                self.recordMetersTime = MBAAudioPlayer(contentsOf: self.mergeExportURL!).duration
                let lower = Int(self.recordMetersTime / 0.2)
                if lower < self.pointXArray.count {
                    self.pointXArray.removeSubrange(Range(uncheckedBounds: (lower: lower, upper: self.pointXArray.count)))
                }

        if isCuted {
            MBAAudio.startRecord()
            sessionCategory(isRecord: true)
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
        topRecordPower.value = 1
        topMusicPower.value = 1
        
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
                    DispatchQueue.main.async {
                        self.mergeExportURL = mergeExportURL
                        MBAProgressHUD.dismiss()
                        self.pushToClick(recordVCClick: recordVCClick!)
                    }
                } else {
                    MBAProgressHUD.showWithStatus("请稍等")
                    MBAAudioUtil.mergeAudio(url1: self.mergeExportURL!, url2: recodedVoiceURL, handleComplet: { (mergeExportURL) in
                        if let mergeExportURL = mergeExportURL {
                            DispatchQueue.main.async {
                                self.mergeExportURL = mergeExportURL
                                MBAProgressHUD.dismiss()
                                self.pushToClick(recordVCClick: recordVCClick!)
                            }
                        } else {
                            MBAProgressHUD.showErrorWithStatus("程序出错，请重录")
                        }
                    })
                }
            })
        } else {
            self.mergeExportURL = MBAAudio.url
            self.pushToClick(recordVCClick: recordVCClick!)
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
        timeLabel.text = TimeInterval(time).getFormatTime()
    }
    
    func timerInit(){
        recordMetersTimer = Timer.scheduledTimer(timeInterval: TimeInterval(kWaveTime), target: self, selector: #selector(recordMetersTimerEvent), userInfo: nil, repeats: true)
        RunLoop.current.add(recordMetersTimer!, forMode: .commonModes)
        recordPowerTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.001), target: self, selector: #selector(updatePower), userInfo: nil, repeats: true)
    }
    
    func timerPause() {
        recordMetersTimer?.fireDate = Date.distantFuture
        recordPowerTimer?.fireDate = Date.distantFuture
    }
    
    func timerContinue() {
        recordMetersTimer?.fireDate = Date()
        recordPowerTimer?.fireDate = Date()
    }
    
    func timerInvalidate(){
        recordMetersTimer?.invalidate()
        recordMetersTimer = nil
        recordPowerTimer?.invalidate()
        recordPowerTimer = nil
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

// MARK: - push
extension RecordViewController {
    
    func pushToClick(recordVCClick: RecordVCClick) {
        
//        self.recordMetersTime = MBAAudioPlayer(contentsOf: self.mergeExportURL!).duration
//        let lower = Int(self.recordMetersTime / 0.2)
//        if lower < self.pointXArray.count {
//            self.pointXArray.removeSubrange(Range(uncheckedBounds: (lower: lower, upper: self.pointXArray.count)))
//        }
        
        switch recordVCClick {
        case .play:
            sessionCategory(isRecord: false)// 播放
            self.performSegue(withIdentifier: "PlayRecordViewController", sender: self)
        case .cut:
            sessionCategory(isRecord: false)
            self.performSegue(withIdentifier: "CutRecordViewController", sender: self)
        case .save:
            actionSave()
        case .reRecord:
            actionReRecord()
        default:
            break
        }
    }
    
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

// MARK: - DubPlayViewDelegate
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
}

// MARK: - 点击后保存图片
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


