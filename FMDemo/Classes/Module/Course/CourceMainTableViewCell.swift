//
//  CourceMainTableViewCell.swift
//  FMDemo
//
//  Created by mba on 17/2/9.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit

enum status {
    case noSave,save
}

class CourceMainTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLable: UILabel!
    
    @IBOutlet weak var statusImg: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var leftbottomLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = UIColor.colorWithHexString(kGlobalBgColor)
        leftbottomLabel.isHidden = true
        setStatus()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}

extension CourceMainTableViewCell {
    func setStatus() {
        // noSave
        statusImg.image = #imageLiteral(resourceName: "course_chapt_state1_ico")
        statusLabel.textColor = UIColor.colorWithHexString("f45e5e")
        
        // save
        statusImg.image = #imageLiteral(resourceName: "course_chapt_state2_ico")
        statusLabel.textColor = UIColor.colorWithHexString("5dd89d")
    }
}
