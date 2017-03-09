//
//  MainTableView.swift
//  FMDemo
//
//  Created by mba on 17/2/9.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit

class MainTableView: RefreshBaseTableView {
    var parentVC: MainViewController?

    /// 加载刷新数据
    override func loadData() {
        KeService.actionGetCourses(start: start, num: num, success: { (bean) in
            if self.action == .loadNew {
                self.dataList?.removeAll()
            }
            if let datas = bean.data {
                
                for data in datas {
                    self.dataList?.append(data)
                }
            }
            self.loadCompleted()

        }) { (error) in
            if 40301 == error.code {
                self.loadError(error, isEmptyData: true)
            } else {
                self.loadError(error, isEmptyData: false)
            }
            
        }
    }
}

// MARK: - tableviewDelegate
extension MainTableView{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let bean = self.dataList?[indexPath.row] as? GetCoursesData {
            if let url = bean.url {
                parentVC?.pushPlayCourseVC(url: url)
            } else {
                parentVC?.pushCourseDetailVC(cid: bean.cid ?? "",title: bean.title ?? "")
            }
        }        
    }
}


// MARK: - DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
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
