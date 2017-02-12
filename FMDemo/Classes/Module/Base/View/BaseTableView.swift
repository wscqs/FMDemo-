//
//  BaseTableView.swift
//  ban
//
//  Created by mba on 16/8/30.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class BaseTableView: UITableView {


    convenience init(frame: CGRect) {
        self.init(frame: frame, style: UITableViewStyle.plain)
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        setDefaultUI()
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented"
        super.init(coder: aDecoder)
        setDefaultUI()
        setUI()
    }
    
    func setDefaultUI() {
//        tableHeaderView = UIView()
//        tableFooterView = UIView()

        
        emptyDataSetSource = self
        emptyDataSetDelegate = self
        backgroundColor = UIColor.colorWithHexString(kGlobalBgColor)
        estimatedRowHeight = 100
        rowHeight = UITableViewAutomaticDimension
    }

    
    func setUI() {
        
    }
    
    
//    func startRequest(isForce: Bool){
//        
//    }

}


extension BaseTableView: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    
//    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
//        return #imageLiteral(resourceName: "course_emptyBgimg")
//    }
    
//    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
//        let attributes = [ NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15.0), NSForegroundColorAttributeName: UIColor.gray]
//        let text = "空数据，重新加载"
//        return NSAttributedString(string: text, attributes: attributes)
//    }
//    
//    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
//        let attributes = [ NSFontAttributeName: UIFont.boldSystemFont(ofSize: 10.0), NSForegroundColorAttributeName: UIColor.gray]
//        let text = "空数据，重新加载"
//        return NSAttributedString(string: text, attributes: attributes)
//    }
    
    //    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
    //
    //    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetDidTap(_ scrollView: UIScrollView!) {
    }
}
