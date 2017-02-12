//
//  BaseTableViewController.swift
//  ban
//
//  Created by mba on 16/7/28.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import UIKit
import MJRefresh
import ObjectMapper
//import DZNEmptyDataSet
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


enum LoadAction {
    case loadNew // 加载最新
    case loadMore // 加载更多
}

class BaseTableViewController: BaseViewController {
    
    /// 默认的CellIdentifier
    var identifier:String = "reusableCellID"
    
    var tableView:UITableView!
    
    /// 动作标识
    var action:LoadAction = .loadNew
    
    /// 当前页，如果后台是从0开始那这里就修改为0
    //    var page:Int = 1
    var start: Int = 1
    
    /// 每页加载多少条
    //    var pageSize:Int = 10
    var num: Int = 10
    
    /// 数据源集合
    var dataList:[Mappable]? = [Mappable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //如果布局中没有tableView，则默认通过代码创建一个全屏的tableView
        if tableView == nil {
            
            let statusHeight = UIApplication.shared.statusBarFrame.height
            let navHeight = navigationController?.navigationBar.frame.height ?? 0
            
            //  判断tabbar是否隐藏无效！！只能这样判断
            var tabBarHeight:CGFloat = 0
            if tabBarItem.title?.characters.count > 0 {
                tabBarHeight = tabBarController!.tabBar.frame.height
            }
           
            let y: CGFloat = (0 == navHeight) ? statusHeight : 0
            
            tableView = RefreshBaseTableView(frame: CGRect(x: 0, y: y, width: self.view.frame.width, height: self.view.frame.height - statusHeight - navHeight - tabBarHeight), style: UITableViewStyle.plain)
            view.addSubview(tableView)

            tableView.tableHeaderView = UIView()
            tableView.tableFooterView = UIView()
            
            tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            tableView.backgroundColor = UIColor.colorWithHexString(kGlobalBgColor)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
//        tableView.emptyDataSetSource = self
//        tableView.emptyDataSetDelegate = self
        
    }

    /**
     初始化参数
     
     - parameter nibName:                 nib名 （nil 为默认，调试用）
     - parameter heightForRowAtIndexPath: 高度：( 0 为自动设置高度）
     - parameter canLoadRefresh:          是否可以刷新
     - parameter canLoadMore:             是否可以加载
     */
    func initWithParams(_ nibName: String?, heightForRowAtIndexPath: CGFloat, canLoadRefresh:Bool, canLoadMore: Bool) {
        if let nib = nibName {
             tableView.register(UINib(nibName: nib, bundle: nil), forCellReuseIdentifier: identifier)            
        }else {
            tableView.register(RefreshBaseTableViewCell.self, forCellReuseIdentifier: identifier)
        }

        if 0 == heightForRowAtIndexPath {
            tableView.estimatedRowHeight = 100
            tableView.rowHeight = UITableViewAutomaticDimension
        } else {
            tableView.rowHeight = heightForRowAtIndexPath
        }
        
        if canLoadRefresh {
            //添加下拉刷新
            tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(BaseTableViewController.loadRefresh))
        }
        
        if canLoadMore {
            //添加上拉加载
//            tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(BaseTableViewController.loadMore))
            tableView.mj_footer = MJRefreshBackNormalFooter(refreshingTarget: self, refreshingAction: #selector(BaseTableViewController.loadMore))
        }
        
    }
    
    /**
     执行刷新
     */
    func loadRefresh(){
        action = .loadNew
        start = 1
        loadData()
    }
    
    /**
     执行加载更多
     */
    func loadMore() {
        action = .loadMore
        start += num
        loadData()
    }
    
    /**
     加载完成
     */
    func loadCompleted() {
        DispatchQueue.main.async { 
            if self.action == .loadNew {
                self.tableView.mj_header.endRefreshing()
            } else {
                self.tableView.mj_footer.endRefreshing()
            }
            self.tableView.reloadData()
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension BaseTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList?.count ?? 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? RefreshBaseTableViewCell
        
        cell?.setContent(tableView, cellForRowAtIndexPath: indexPath, dataList: dataList!)
        
        return cell!
    }
}


extension BaseTableViewController {
    //去掉UItableview headerview黏性
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView == tableView)
        {
            let sectionHeaderHeight = TABLEVIEW_TITLE_HEIGHT;
            if (scrollView.contentOffset.y<=sectionHeaderHeight && scrollView.contentOffset.y>=0) {
                scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
            } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
                scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
            }
        }
    }
}


//// MARK: - DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
//extension BaseTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
//    
//    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
//        return UIImage(named: "avator1")
//    }
//    
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
//    
//    //    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
//    //
//    //    }
//    
//    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
//        tableView.mj_footer = nil
//        return true
//    }
//}

