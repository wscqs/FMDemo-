//
//  MainTableViewCell.swift
//  FMDemo
//
//  Created by mba on 17/2/9.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit
import ObjectMapper

class MainTableViewCell: RefreshBaseTableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusImg: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    override func setContent(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, dataList: [Mappable]) {
        guard let bean = dataList[indexPath.row] as? GetCoursesData else{return}
        title.text = bean.title
        timeLabel.text = bean.createtime
        
//        if "recorded" == bean.state {
//            status(isRecord: true)
//        } else if "unrecorded" == bean.state {
//            status(isRecord: false)
//        } else if "disable" == bean.state {
//            
//        }
        "unrecorded" == bean.state ? status(isRecord: false) : status(isRecord: true)
        
//        print(bean.title,bean.createtime,bean.state)
    }
    
    func status(isRecord: Bool) {
        if isRecord {
            statusImg.image = #imageLiteral(resourceName: "course_chapt_state2_ico")
            statusLabel.text = "已保存"
            statusLabel.textColor = UIColor.colorWithHexString("5dd89d")
        } else {
            statusImg.image = #imageLiteral(resourceName: "course_chapt_state1_ico")
            statusLabel.text = "未录制"
            statusLabel.textColor = UIColor.colorWithHexString("f45e5e")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.backgroundColor = UIColor.colorWithHexString(kGlobalBgColor)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
