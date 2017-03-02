//
//  SeletceDubViewController.swift
//  FMDemo
//
//  Created by mba on 17/1/13.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit
import AVFoundation

class SeletceDubViewController: UITableViewController {
    
    var selectDubURLBlock: ((URL) -> Void)?
    var oldBtn:UIButton?
    var btn = UIButton()
    
    var dubURLArray = [Bundle.main.url(forResource: "配乐1", withExtension: "mp3")!,
                       Bundle.main.url(forResource: "纯音乐", withExtension: "mp3")!,
                       Bundle.main.url(forResource: "新闻联播开场", withExtension: "mp3")!]
    var titleNameArray = [String]()
    
    var player: AVPlayer?
    
    var playBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "select_dub_add-music3"), for: .normal)
        btn.setTitle("试听", for: .normal)
        btn.setImage(#imageLiteral(resourceName: "select_dub_add-music2"), for: .selected)
        btn.setTitle("暂停", for: .selected)
        btn.sizeToFit()
        return btn
    }()
  
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = UIColor.colorWithHexString(kGlobalBgColor)
        title = "增加配乐"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        
        for dubURL in dubURLArray {
            titleNameArray.append(dubURL.lastPathComponent.components(separatedBy: ".").first!)
        }
        
        player = AVPlayer()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        player?.pause()
        oldBtn?.isSelected = false
    }
    
    
    
    func playEnd() {
        oldBtn?.isSelected = false
        player?.currentItem?.seek(to: CMTime(value: 0, timescale: 10))
    }
}


extension SeletceDubViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleNameArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "SeletceDubTabelViewCell")
        cell.textLabel?.text = titleNameArray[indexPath.row]
        cell.detailTextLabel?.text = "00:30"
        cell.imageView?.image = #imageLiteral(resourceName: "select_dub_add-music1")
        btn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        btn.setImage(#imageLiteral(resourceName: "select_dub_add-music3"), for: .normal)
        btn.setTitle("试听", for: .normal)
        btn.setImage(#imageLiteral(resourceName: "select_dub_add-music2"), for: .selected)
        btn.setTitle("暂停", for: .selected)
        btn.setTitleColor(UIColor.lightGray, for: .selected)
        btn.setTitleColor(UIColor.lightGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.titleEdgeInsets = UIEdgeInsets(top: btn.imageView!.frame.size.height + 5, left: -btn.imageView!.frame.size.width, bottom: 0, right: 0)
        btn.imageEdgeInsets = UIEdgeInsets(top: -btn.titleLabel!.bounds.size.height, left: 2, bottom: 0, right: -btn.titleLabel!.bounds.size.width)
        btn.addTarget(self, action: #selector(actionClick(sender:)), for: .touchUpInside)
        btn.tag = indexPath.row
        cell.accessoryView = btn

        return cell
    }
    
    func actionClick(sender: UIButton) {
        if sender == oldBtn { // 同一按钮
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                player?.play()
            } else {
                player?.pause()
            }
        } else { // 不同按钮
            oldBtn?.isSelected = false
            sender.isSelected = !sender.isSelected
            oldBtn = sender
            
            NotificationCenter.default.removeObserver(self)
            let playItem = AVPlayerItem(url: dubURLArray[sender.tag])
            player?.replaceCurrentItem(with: playItem)
            NotificationCenter.default.addObserver(self, selector: #selector(playEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playItem)
            player?.play()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectDubURLBlock?(dubURLArray[indexPath.row])
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "推荐配乐"
//    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "     推荐配乐"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.gray
        label.sizeToFit()
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}
