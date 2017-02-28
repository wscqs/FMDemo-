//
//  MainTableView.swift
//  FMDemo
//
//  Created by mba on 17/2/9.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit

fileprivate var kMainCellId = "MainTableViewCell"
class MainTableView: RefreshBaseTableView {
    var parentVC: MainViewController?

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
            // 缓存就更新数据，服务端数据结束刷新
            //                        (bean.isCache) ? self.reloadData() : self.loadCompleted()
            self.loadCompleted()
//            if bean.data?.count ?? 0 < 10 {
//                self.mj_footer.isHidden = true
//            }

        }) { (error) in
            if 40301 == error.code {
                self.loadError(error, isEmptyData: true)
            } else {
                self.loadError(error, isEmptyData: false)
            }
            
        }
    }
}

//extension MainTableView: UITableViewDelegate, UITableViewDataSource{
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//         return 3
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = dequeueReusableCell(withIdentifier: kMainCellId, for: indexPath)
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        parentVC?.pushCourseDetailVC()
//    }
//
//}

extension MainTableView{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let bean = self.dataList?[indexPath.row] as? GetCoursesData {
            parentVC?.pushCourseDetailVC(cid: bean.cid ?? "",title: bean.title ?? "")
        }        
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
