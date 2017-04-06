//
//  CourceMainTableView.swift
//  FMDemo
//
//  Created by mba on 17/2/9.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit

fileprivate var kMainCellId = "CourceMainTableViewCell"
class CourceMainTableView: RefreshBaseTableView {
 
    var parentVC: CourceMainViewController?
    var cid: String!
    
    fileprivate var tbHeadView = CourceHeadTbView.courceHeadTbView()
    fileprivate var footAddBtn: UIButton = {
        let footAddBtn = UIButton()
        footAddBtn.setImage(UIImage.init(named: "add"), for: .normal)
        footAddBtn.adjustsImageWhenHighlighted = false
        footAddBtn.backgroundColor = UIColor.colorWithHexString("41A0FD")
        footAddBtn.addTarget(self, action: #selector(actionAdd(sender:)), for: .touchUpInside)
        footAddBtn.layer.cornerRadius = 5
        footAddBtn.layer.masksToBounds = true
        return footAddBtn
    }()
    fileprivate var tbFootView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 80))
    fileprivate var alert: UIAlertController?

    override func setUI() {
        let nib = UINib(nibName: kMainCellId, bundle: nil)
        register(nib, forCellReuseIdentifier: kMainCellId)
        delegate = self
        dataSource = self
        separatorStyle = .none
        
        tableHeaderView = tbHeadView
        tbFootView.backgroundColor = UIColor.clear
        tbFootView.addSubview(footAddBtn)
        footAddBtn.frame = CGRect(x: 10, y: 20, width: tbFootView.frame.size.width - 20, height: 40)
        tableFooterView = tbFootView

        mj_footer.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    

    
    override func loadData() {
        KeService.actionGetMaterials(cid: cid, success: { (bean) in
            self.dataList = bean.data
            self.loadCompleted()
            self.changceCourseStatus()
        }) { (error) in
            self.loadError(error)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}




// MARK: -
extension CourceMainTableView {
    
    /// 设置hbHeadView
    open func setcid(cid: String, title: String) {
        self.cid = cid
        tbHeadView.cid = cid
        tbHeadView.titleLabel.text = title
    }
    
    fileprivate func changceCourseStatus() {
        
        NotificationCenter.default.post(name: .shouldReLoadMainData, object: nil, userInfo: nil)
        
        var isComplet = true
        for bean in (self.dataList as? [GetMaterialsData])! {
            if "unrecorded" == bean.state {
                isComplet = isComplet && false
            } else if "recorded" == bean.state {
                isComplet = isComplet && true
            }
        }
        if isComplet {
            tbHeadView.courceStatusLabel.text = "课程未上架"
        }else{
            tbHeadView.courceStatusLabel.text = "课程未完善"
        }
    }
}

extension CourceMainTableView {
    func actionAdd(sender: UIButton) {
        self.alert = UIAlertController(title: "\n\n", message: "", preferredStyle: .alert)
        let textView = BorderTextView(frame: CGRect(x: 5, y: 5, width: 270 - 10, height: 80), textContainer: nil)
        textView.setPlaceholder(kCreatMaterialTitleString, maxTip: 50)        
        alert?.view.addSubview(textView)
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: { (action) in
            if textView.text.isEmpty {
                MBAProgressHUD.showInfoWithStatus("增加章节失败，章节标题不能为空")
                return
            }
            KeService.actionMaterial(cid: self.cid, title: textView.text, success: { (bean) in
                
                let object = GetMaterialsData(JSON: ["time":"0", "mid": bean.mid ?? "", "title": textView.text, "state": "unrecorded"])
                self.dataList?.append(object!)
                let indexPath = IndexPath(row: (self.dataList?.count)!-1, section: 0)
                self.insertRows(at: [indexPath], with: .right)
                self.changceCourseStatus()
            }, failure: { (error) in
            })

        })
        alert?.addAction(cancelAction)
        alert?.addAction(okAction)
        
        self.parentVC?.present(alert!, animated: true, completion: {
            textView.becomeFirstResponder()
        })
    }
}

extension CourceMainTableView {

    // 有headTitle 就设置高度
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleHeadLabel = UILabel()
        titleHeadLabel.text = "章节（课程不分章节时，默认为单一章节课程）"
        let titleH:CGFloat = 30
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: titleH))
        titleHeadLabel.frame = CGRect(x: 10, y: 5, width: view.size.width, height: titleH)
        titleHeadLabel.font = UIFont.systemFont(ofSize: 13)
        view.addSubview(titleHeadLabel)
        titleHeadLabel.textColor = UIColor.gray
        view.backgroundColor = UIColor.colorWithHexString(kGlobalBgColor)
        return view
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        let sourceIndex = sourceIndexPath.row
//        let destinationIndex = destinationIndexPath.row
//        let object = dataList?[sourceIndex]
//        self.dataList?.remove(at: sourceIndex)
//        self.dataList?.insert(object!, at: destinationIndex)
//    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
      
        let reNameAction = UITableViewRowAction(style: .normal, title: "编辑") { (action, index) in

            let sourceIndex = indexPath.row
            let object = self.dataList?[sourceIndex] as? GetMaterialsData
            

            self.alert = UIAlertController(title: "\n\n", message: "", preferredStyle: .alert)
            let textView = BorderTextView(frame: CGRect(x: 5, y: 5, width: 270 - 10, height: 80), textContainer: nil)
            textView.setPlaceholder(kCreatMaterialTitleString, maxTip: 50)
            self.alert?.view.addSubview(textView)
            textView.text = "\(object?.title ?? "")"
            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: { (action) in
                self.endEditing(true)
                tableView.setEditing(false, animated: false)
            })
            let okAction = UIAlertAction(title: "确定", style: .default, handler: { (action) in
                self.endEditing(true)
                
                if textView.text.isEmpty {
                    MBAProgressHUD.showInfoWithStatus("修改章节标题失败，章节标题不能为空")
                    return
                }
                if textView.text != object?.title! {
                    let oldText = object?.title!
                    KeService.actionMaterial(mid: object?.mid!, cid: self.cid, title: textView.text, success: { (bean) in
                        
                    }, failure: { (error) in
                        object?.title = oldText
                        self.dataList?[sourceIndex] = object!
                        tableView.reloadRows(at: [index], with: .right)
                    })
                }
                object?.title = textView.text
                self.dataList?[sourceIndex] = object!
                tableView.reloadRows(at: [index], with: .right)
            })
            self.alert?.addAction(cancelAction)
            self.alert?.addAction(okAction)

            self.parentVC?.navigationController?.present(self.alert!, animated: true, completion: {
                
            })
        }
        
        let moveAction = UITableViewRowAction(style: .normal, title: "向上") { (action, index) in
            let sourceIndex = indexPath.row
            if sourceIndex == 0 { return }
            let destinationIndex = sourceIndex - 1
            let object = self.dataList?[sourceIndex]
            self.dataList?.remove(at: sourceIndex)
            self.dataList?.insert(object!, at: destinationIndex)
            let toIndexPath = IndexPath(row: destinationIndex, section: 0)
            tableView.moveRow(at: indexPath, to: toIndexPath)
            tableView.setEditing(false, animated: true)
            
            var sort = [String]()
            for bean in self.dataList! {
                guard let object = bean as? GetMaterialsData else { return}
                sort.append(object.mid ?? "")
            }
            
            KeService.actionMaterialSort(cid:self.cid, sort: sort, success: { (bean) in
                
            }, failure: { (error) in
                self.dataList?.remove(at: destinationIndex)
                self.dataList?.insert(object!, at: sourceIndex)
                tableView.moveRow(at: indexPath, to: toIndexPath)
            })
        }
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "删除") { (action, index) in
            if self.dataList?.count ?? 0 <= 1 {
                MBAProgressHUD.showErrorWithStatus("章节需要保留一个")
                return
            }
            let object = self.dataList?[index.row] as? GetMaterialsData
            KeService.actionMaterialDelete(mid: object?.mid ?? "", success: { (bean) in
                
            }, failure: { (error) in
                self.dataList?.append(object!)
                tableView.insertRows(at: [index], with: .fade)
                MBAProgressHUD.showInfoWithStatus("删除失败")
            })
            
            self.dataList?.remove(at: index.row)
            tableView.deleteRows(at: [index], with: .fade)
            self.changceCourseStatus()
        }
        
        reNameAction.backgroundColor = UIColor.colorWithHexString("62d9a0")
        moveAction.backgroundColor = UIColor.colorWithHexString("feba6a")
        deleteAction.backgroundColor = UIColor.colorWithHexString("f45e5e")
        return [deleteAction, moveAction, reNameAction]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let bean = self.dataList?[indexPath.row] as? GetMaterialsData else { return }
        if bean.url?.isEmpty ?? true{
            parentVC?.pushToRecordViewController(mid: (bean.mid)!)
        } else {
            parentVC?.pushToPlayCourceMaterialViewController(url: (bean.url)!)
        }        
    }
}

extension CourceMainTableView {
    //键盘的出现
    func keyBoardWillShow(_ notification: Notification){
        //获取userInfo
        let kbInfo = notification.userInfo
        //获取键盘的size
        let kbRect = (kbInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        //键盘的y偏移量
        let changeY = kbRect.origin.y - UIScreen.main.bounds.height
        //键盘弹出的时间
//        let duration = kbInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        //界面偏移动画
        UIView.animate(withDuration: 0.5) {
            self.alert?.view.transform = CGAffineTransform(translationX: 0, y: changeY/2)
        }
    }
    
    //键盘的隐藏
    func keyBoardWillHide(_ notification: Notification){
    }
}
