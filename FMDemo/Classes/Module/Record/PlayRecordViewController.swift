//
//  PlayRecordViewController.swift
//  FMDemo
//
//  Created by mba on 17/1/25.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit
import AVFoundation

class PlayRecordViewController: UIViewController {
    var url: URL?
    var pointXArray: [CGFloat]?
    var mid: String!

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bannerImg: UIImageView!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var slider: PlayBarWaveView!
    
    @IBOutlet weak var listenPlayBtn: UIButton!
    @IBOutlet weak var listenStatusLabel: UILabel!
    @IBOutlet weak var cutBtn: UIButton!
    @IBOutlet weak var savaBtn: UIButton!

    /// 保存点击图片
    var imgDictArray: [RecordSelectImgModel] = [RecordSelectImgModel]()
    var thumbPointXIndex: Int = 0
    var totalTime: TimeInterval {
        return Double(pointXArray?.count ?? 0) * 0.2
    }
    
    
    var sliderTime: TimeInterval = 0 {
        didSet{
            player?.currentTime = sliderTime
            updateTime()
        }
    }
    
    var sliderTimer: Timer?
    var player: MBAAudioPlayer!
    
    
    deinit {
        print("deinit----------")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let url = url else {
            return
        }
        player = MBAAudioPlayer(contentsOf: url)
//        player.player?.delegate = self
        totalTimeLabel.text = totalTime.getFormatTime()
        
        slider.pointXArray = pointXArray
//        slider.pointXArray = testArray
        self.actionPlayClick(sender: self.listenPlayBtn)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        MBAProgressHUD.show()
////        slider.pointXArray = pointXArray
//        slider.pointXArray = testArray
//        slider.isRenderSucess = { isRenderRuselt in
//            if isRenderRuselt  {
//                self.slider.slider.isHidden = false
//                MBAProgressHUD.dismiss()
//                self.actionPlayClick(sender: self.listenPlayBtn)
//            }
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.stopPlay()
        player = nil
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        if self.isViewLoaded && (self.view.window != nil) {
            self.view = nil
        }
    }
    
    func updateTime(isTimer: Bool? = false) {
        if thumbPointXIndex >= (pointXArray?.count ?? 0){
            stopPlay()
            thumbPointXIndex = 0
            bannerImg.image = #imageLiteral(resourceName: "record_bannerBg")
            return
        }
        
        if isTimer! {
            thumbPointXIndex = thumbPointXIndex + 1
            slider.setPlayProgress(thumbPointXIndex: thumbPointXIndex)
        }
        
        timeLabel.text = (Double(thumbPointXIndex) * 0.2).getFormatTime()
        setSpannerImg()
    }
    
    func sliderTimerEvent() {
        updateTime(isTimer: true)
    }

}

extension PlayRecordViewController {
    func setup() {
        listenPlayBtn.addTarget(self, action: #selector(actionPlayClick), for: .touchUpInside)
        listenPlayBtn.adjustsImageWhenHighlighted = false
        savaBtn.addTarget(self, action: #selector(actionSave), for: .touchUpInside)
        cutBtn.addTarget(self, action: #selector(actionCut), for: .touchUpInside)
        slider.delegate = self
    }
}

extension PlayRecordViewController {
    //MARK: 点击播放
    func actionPlayClick(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected { // 播放状态
            listenStatusLabel.text = "暂停"
            thumbPointXIndex == 0 ? startPlay() : continuePlay()
            
        } else {
            listenStatusLabel.text = "播放"
            pausePlay()
        }
    }
    
    func actionSave() {
        listenStatusLabel.text = "播放"
        pausePlay()
        
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
                mp3url = MBAAudioUtil.changceToMp3(of: self.url, mp3Name: Date().formatDate)
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
                
                KeService.actionRecordAudio(mid: self.mid, file: mp3Data!, time: String(self.totalTime),ware: wareArray, success: { (bean) in
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

    
    func actionCut(sender: UIButton) {
        pausePlay()
        
        
        let cutVC = UIStoryboard.init(name: "Record", bundle: nil).instantiateViewController(withIdentifier: "CutRecordViewController") as? CutRecordViewController
        cutVC?.url = self.url
        cutVC?.pointXArray = self.pointXArray
        cutVC?.imgDictArray = self.imgDictArray
        
        navigationController?.pushViewController(cutVC!, animated: true)
        for i in 0 ..< (navigationController?.viewControllers.count ?? 0){
            if navigationController?.viewControllers[i] is PlayRecordViewController {
                navigationController?.viewControllers.remove(at: i)
                break
            }
        }
    }
}

// MARK: - Timer
extension PlayRecordViewController {
    func initTimer() {
        sliderTimer = Timer.scheduledTimer(timeInterval: kWaveTime, target: self, selector: #selector(sliderTimerEvent), userInfo: nil, repeats: true)
    }
    
    func pauseTimer() {
        sliderTimer?.fireDate = Date.distantFuture
    }
    
    func continueTimer() {
        sliderTimer?.fireDate = Date()
    }
    
    func stopTimer() {
        sliderTimer?.invalidate()
        sliderTimer = nil
    }
}

// MARK: - playStatus
extension PlayRecordViewController {
    
    func startPlay() {
        sliderTime = kWaveTime
        player?.startPlay()
        initTimer()
    }
    
    func pausePlay() {
        player?.pausePlay()
        pauseTimer()
    }
    
    func continuePlay() {
        player?.continuePlay()
        continueTimer()
    }
    
    func stopPlay() {
        pauseTimer()
        listenPlayBtn.isSelected = false
        listenStatusLabel.text = "播放"
    }
}

// MARK: - 图片播放设置
extension PlayRecordViewController {
    
    func setSpannerImg() {
        for (index,imgDict) in imgDictArray.enumerated() {
            if thumbPointXIndex == imgDict.thumbPointXIndex {
                bannerImg.image = imgDict.image
                imgAnimation()
                break
            }
            if index == 0 {
                if thumbPointXIndex < imgDictArray[index].thumbPointXIndex {
                    bannerImg.image = #imageLiteral(resourceName: "record_bannerBg")
                    imgAnimation()
                    break
                }
            } else if index == imgDictArray.count - 1 {
                if thumbPointXIndex >= imgDictArray[index].thumbPointXIndex {
                    bannerImg.image = imgDictArray[index].image
                    imgAnimation()
                    break
                } else {
                    bannerImg.image = imgDictArray[index - 1].image
                    imgAnimation()
                    break
                }
            } else {
                if imgDictArray[index - 1].thumbPointXIndex < thumbPointXIndex &&
                    thumbPointXIndex < imgDictArray[index].thumbPointXIndex {
                    bannerImg.image = imgDictArray[index - 1].image
                    imgAnimation()
                    break
                }
            }
        }
    }
    
    func imgAnimation() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionFade
        bannerImg.layer.add(transition, forKey: nil)
    }
}

// MARK: - 图片播放设置
extension PlayRecordViewController: PlayBarWaveViewDelegate {
    func changceTimeLabel(cutBarWaveView: PlayBarWaveView, thumbPointXIndex: Int) {
        pausePlay()
        self.thumbPointXIndex = thumbPointXIndex
        sliderTime = Double(thumbPointXIndex) * 0.2

        if listenPlayBtn.isSelected {// 在播放中
            continuePlay()
        } else {
            
        }
    }
}
