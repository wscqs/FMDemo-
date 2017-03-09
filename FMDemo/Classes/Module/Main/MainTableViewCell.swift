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
        let state = bean.state ?? "unrecorded"
        status(state: state)
    }
    
    func status(state: String) {
        //state：unrecorded未录制   enable（会有url地址） 上架 disable 已保存
        if "enable" == state {
            statusImg.image = #imageLiteral(resourceName: "course_chapt_state3_ico")
            statusLabel.text = "上架中"
            statusLabel.textColor = UIColor.colorWithHexString("58acff")
        } else if "unrecorded" == state {
            statusImg.image = #imageLiteral(resourceName: "course_chapt_state1_ico")
            statusLabel.text = "未录制"
            statusLabel.textColor = UIColor.colorWithHexString("f45e5e")
        } else if "disable" == state {
            statusImg.image = #imageLiteral(resourceName: "course_chapt_state2_ico")
            statusLabel.text = "已保存"
            statusLabel.textColor = UIColor.colorWithHexString("5dd89d")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor.colorWithHexString(kGlobalBgColor)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
