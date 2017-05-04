import UIKit
import MJRefresh
import ObjectMapper
import DZNEmptyDataSet

class RefreshBaseTableView: UITableView {
        
    /// 标题头
    var titleHeadLabel:UILabel = UILabel()
    
    /// 动作标识
    var action:LoadAction = .loadNew
    
    /// 当前页，如果后台是从0开始那这里就修改为0
    var start: Int = 0
    
    /// 上一个的start
    var startBack: Int = 0
    
    /// 每页加载多少条
    var num: Int = 10
    
    /// 数据源id集合
    var ids:[String] = []
    /// 数据源集合
    var dataList:[Mappable]? = [Mappable]()
        
    /// 默认的CellIdentifier
    fileprivate var identifier:String = "reusableCellID"
    
    fileprivate var canLoadMore:Bool = false
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        setDefauteUI()
        setUI()
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
            register(UINib(nibName: nib, bundle: nil), forCellReuseIdentifier: identifier)
        }else {
            register(RefreshBaseTableViewCell.self, forCellReuseIdentifier: identifier)
        }
        
        if 0 == heightForRowAtIndexPath {
            estimatedRowHeight = 100
            rowHeight = UITableViewAutomaticDimension
        } else {
            rowHeight = heightForRowAtIndexPath
        }
        
        if !canLoadRefresh {
            //添加下拉刷新
            mj_header.isHidden = true
        }
        
//        if !canLoadMore {
//            //添加上拉加载
//            mj_footer.isHidden = true
//        }
        
        self.canLoadMore = canLoadMore
        
    }
    
    // 请求开始
    func start(_ force: Bool) {
        if(force){
            if (dataList?.count ?? 0) > 0 {
                return
            }
            mj_header.beginRefreshing()
        }
    }
    
    /// 子类加载tableView数据
    func loadData() {
        mj_header.endRefreshing()
        mj_footer.endRefreshing()
        //        alamofireManager.
    }
    
    /// 子类加载tableView其余的数据（头部等另外请求的）
    func loadTbOtherData() {
        
    }
    
    
    /// idsModelHandle 加载完处理
    ///
    /// - parameter idsModel: IdsModel
    ///
    /// - returns: newsId 数组或nil
    func idsModelHandle(idsModel: IdsModel?) -> [String]?{
        if let ids = idsModel?.ids{
            return idHandle(ids: ids)
        } else {
            self.loadCompleted()
            return nil
        }
    }

    /// 加载前初始化
    func loadInit() {
        MBAProgressHUD.show()
        titleHeadLabel.text = ""
        tableHeaderView = UIView()
        ids.removeAll()
        dataList?.removeAll()
        start = 0
        self.reloadData()
    }

    /// 加载完成
    ///
    /// - parameter isEmptyData: 是否已经拿到空数据
    func loadCompleted(isEmptyData: Bool = false) {
        DispatchQueue.main.async {
            MBAProgressHUD.dismiss()
            self.mj_header.endRefreshing()
            if isEmptyData {
                self.mj_footer.endRefreshingWithNoMoreData()
            }else{
                self.mj_footer.endRefreshing()
                self.reloadData()
            }
        }
    }
    
    /// 加载出错（start 回退）
    ///
    /// - parameter error: error
    func loadError(_ error: NSError) {
        self.start -= self.num
        self.loadCompleted()
    }
    
    func loadError(_ error: NSError, isEmptyData: Bool = false) {
        self.start -= self.num
        self.loadCompleted(isEmptyData: isEmptyData)
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - private
extension RefreshBaseTableView {
    
    /// 执行刷新
    @objc fileprivate func loadRefresh(){
        mj_footer.endRefreshing()
        action = .loadNew
        start = 0
        loadTbOtherData()
        loadData()        
    }
    
    
    /// 执行加载更多
    @objc fileprivate func loadMore() {
        mj_header.endRefreshing()
        action = .loadMore
        startBack = start
        start += num
        loadData()
    }
    
    /// id 加载完处理
    ///
    /// - parameter ids: ids 数组
    ///
    /// - returns: newsId 数组或nil
    fileprivate func idHandle(ids: [String]) -> [String]?{
        if ids.isEmpty {
            self.loadCompleted(isEmptyData: true)
            return nil
        }
        if self.action == .loadNew {
            self.ids.removeAll()
        }
        var newIds:[String] = []
        for id in ids {            
            if !self.ids.contains(id){
                newIds.append(id)
            }
        }
        if newIds.isEmpty {
            self.loadCompleted()
            return nil
        }
        return newIds
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension RefreshBaseTableView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        mj_footer.isHidden = !((self.dataList?.count ?? 0) > 0)
        return self.dataList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? RefreshBaseTableViewCell
        guard let dataList = dataList else {
            return cell!
        }
        cell?.setContent(tableView, cellForRowAtIndexPath: indexPath, dataList: dataList)
        return cell!
    }
    
    // 有headTitle 就设置高度
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (titleHeadLabel.text?.isEmpty ?? true) ? 0 : 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (titleHeadLabel.text?.isEmpty ?? true) {
            return nil
        }
        let titleH:CGFloat = 30
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: titleH))
        titleHeadLabel.frame = CGRect(x: 20, y: 0, width: 200, height: titleH)
        titleHeadLabel.font = UIFont.systemFont(ofSize: 11)
        titleHeadLabel.textColor = UIColor.lightGray
        view.addSubview(titleHeadLabel)
        return view
    }
    
}

// MARK: - setUI
extension RefreshBaseTableView {
    func setDefauteUI() {
        
        //设置标头的高度为特小值 （不能为零 为零的话苹果会取默认值就无法消除头部间距了）
        tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 0.001))
        tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 0.001))
        
        delegate = self
        dataSource = self
        
        emptyDataSetSource = self
        emptyDataSetDelegate = self
        
        separatorStyle = UITableViewCellSeparatorStyle.none
        backgroundColor = UIColor.colorWithHexString(kGlobalBgColor)
        
        mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(RefreshBaseTableView.loadRefresh))
        mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(RefreshBaseTableView.loadMore))

    }
    
    func setUI() {
        
    }
}

//// MARK: - 去掉UItableview headerview黏性
//extension RefreshBaseTableView {
//    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if (isTitleFix == true && scrollView == self)
//        {
//            let sectionHeaderHeight = TABLEVIEW_TITLE_HEIGHT;
//            if (scrollView.contentOffset.y<=sectionHeaderHeight && scrollView.contentOffset.y>=0) {
//                scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//            } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
//                scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//            }
//        }
//    }
//}


// MARK: - DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
extension RefreshBaseTableView: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    
//    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
//        return UIImage(named: "none")
//    }
//    
//    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
//        let attributes = [ NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15.0), NSForegroundColorAttributeName: UIColor.gray]
//        let text = "没有数据，请刷新"
//        return NSAttributedString(string: text, attributes: attributes)
//    }
    
//    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
//        let attributes = [ NSFontAttributeName: UIFont.boldSystemFontOfSize(10.0), NSForegroundColorAttributeName: UIColor.grayColor()]
//        let text = "关注精英后可捕捉最新动态"
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
        loadRefresh()
    }
    
    func emptyDataSetWillAppear(_ scrollView: UIScrollView!) {
        mj_footer.isHidden = true
    }
    
    func emptyDataSetWillDisappear(_ scrollView: UIScrollView!) {
        mj_footer.isHidden = !canLoadMore
    }
}

