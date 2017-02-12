//
//  MainTableView.swift
//  FMDemo
//
//  Created by mba on 17/2/9.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit

fileprivate var kMainCellId = "MainTableViewCell"
class MainTableView: BaseTableView {
    var parentVC: MainViewController?
    override func setUI() {
        let nib = UINib(nibName: kMainCellId, bundle: nil)
        register(nib, forCellReuseIdentifier: kMainCellId)
        delegate = self
        dataSource = self
        separatorStyle = .none
    }
}

extension MainTableView: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: kMainCellId, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        parentVC?.pushCourseDetailVC()
    }

}


extension MainTableView {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "course_emptyBgimg")
    }
    
     func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [ NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15.0), NSForegroundColorAttributeName: UIColor.colorWithHexString("5bacff")]
        let text = "当前无任何课程"
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 20
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -60
    }
}
