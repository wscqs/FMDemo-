//
//  CourceMainTableViewCell.swift
//  FMDemo
//
//  Created by mba on 17/2/9.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit
import ObjectMapper

enum status {
    case noSave,save
}

class CourceMainTableViewCell: RefreshBaseTableViewCell {

    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var statusImg: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func setContent(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, dataList: [Mappable]) {
        guard let bean = dataList[indexPath.row] as? GetMaterialsData else{return}
        titleLable.text = bean.title
        if "unrecorded" == bean.state {
            status(isRecord: false)
        } else if "recorded" == bean.state{
            status(isRecord: true)
        }
       statusLabel.text = Double(bean.time!)?.getFormatTime()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.colorWithHexString(kGlobalBgColor)
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension CourceMainTableViewCell {
    
    func status(isRecord: Bool) {
        if isRecord {
            statusImg.image = #imageLiteral(resourceName: "course_chapt_state2_ico")
            statusLabel.textColor = UIColor.colorWithHexString("5dd89d")
        } else {
            statusImg.image = #imageLiteral(resourceName: "course_chapt_state1_ico")
            statusLabel.textColor = UIColor.colorWithHexString("f45e5e")
        }
    }
}
