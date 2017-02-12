//
//  BaseTableViewCell.swift
//  ban
//
//  Created by mba on 16/7/28.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import UIKit
import ObjectMapper

class RefreshBaseTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
    }

    /**
     设置展示内容
     
     - parameter tableView: tableView
     - parameter indexPath: indexPath
     - parameter dataList:  dataList
     */
    func setContent(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, dataList: [Mappable]) {
        //do something
    }
}
