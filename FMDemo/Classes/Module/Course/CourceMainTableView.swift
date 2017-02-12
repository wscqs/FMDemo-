//
//  CourceMainTableView.swift
//  FMDemo
//
//  Created by mba on 17/2/9.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit

fileprivate var kMainCellId = "CourceMainTableViewCell"
class CourceMainTableView: BaseTableView {
 
    var parentVC: CourceMainViewController?
    var dataArray = ["1","2","3","4","5"]
    var tbHeadView = CourceHeadTbView.courceHeadTbView()
    var footAddBtn: UIButton = {
        let footAddBtn = UIButton()
        footAddBtn.setTitle("+", for: .normal)
        footAddBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        footAddBtn.setTitleColor(UIColor.white, for: .normal)
        footAddBtn.backgroundColor = UIColor.colorWithHexString("41A0FD")
        footAddBtn.addTarget(self, action: #selector(actionAdd(sender:)), for: .touchUpInside)
        footAddBtn.layer.cornerRadius = 5
        footAddBtn.layer.masksToBounds = true
        return footAddBtn
    }()
    
    var tbFootView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 60))

    override func setUI() {
        let nib = UINib(nibName: kMainCellId, bundle: nil)
        register(nib, forCellReuseIdentifier: kMainCellId)
        delegate = self
        dataSource = self
        separatorStyle = .none
        
        tableHeaderView = tbHeadView
        tbFootView.backgroundColor = UIColor.clear
        tbFootView.addSubview(footAddBtn)
        footAddBtn.frame = CGRect(x: 10, y: 5, width: tbFootView.frame.size.width - 20, height: 35)
        tableFooterView = tbFootView
        
    }
}

extension CourceMainTableView {
    func actionAdd(sender: UIButton) {
        let alert = UIAlertController(title: "\n\n", message: "", preferredStyle: .alert)
        let textView = BorderTextView(frame: CGRect(x: 5, y: 5, width: 270 - 10, height: 80), textContainer: nil)
        textView.setPlaceholder(kCreatTitleString, maxTip: 50)
        alert.view.addSubview(textView)
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: { (action) in
            if textView.text.isEmpty { return }
            self.dataArray.append(textView.text)
            let indexPath = IndexPath(row: self.dataArray.count - 1, section: 0)
            DispatchQueue.main.async {
                self.insertRows(at: [indexPath], with: .right)
                self.scrollViewToBottom()
            }
            
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        self.parentVC?.present(alert, animated: true, completion: {
            
        })
    }
    
    func scrollViewToBottom() {
//        if (self.contentSize.height > self.bounds.size.height) {
//            let offset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height)
//            self.setContentOffset(offset, animated: false)
//        }
//        let offset = CGPoint(x: CGFloat(0), y: CGFloat(MAXFLOAT))
//        self.setContentOffset(offset, animated: false)
    }
}

extension CourceMainTableView: UITableViewDelegate, UITableViewDataSource{

    // 有headTitle 就设置高度
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleHeadLabel = UILabel()
        titleHeadLabel.text = "章节（课程不分章节时，默认为单一章节课程）"
        let titleH:CGFloat = 30
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: titleH))
        titleHeadLabel.frame = CGRect(x: 10, y: 5, width: view.size.width, height: titleH)
        titleHeadLabel.font = UIFont.systemFont(ofSize: 11)
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
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceIndex = sourceIndexPath.row
        let destinationIndex = destinationIndexPath.row
        let object = dataArray[sourceIndex]
        self.dataArray.remove(at: sourceIndex)
        self.dataArray.insert(object, at: destinationIndex)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let reNameAction = UITableViewRowAction(style: .normal, title: "编辑") { (action, index) in

            let sourceIndex = indexPath.row
            let object = self.dataArray[sourceIndex]

            let alert = UIAlertController(title: "\n\n\n", message: "", preferredStyle: .alert)
            let textView = BorderTextView(frame: CGRect(x: 5, y: 5, width: 270 - 10, height: 100), textContainer: nil)
            textView.setPlaceholder(kCreatTitleString, maxTip: 50)
            alert.view.addSubview(textView)
            textView.text = "\(object)"
            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: { (action) in
                tableView.setEditing(false, animated: false)
            })
            let okAction = UIAlertAction(title: "确定", style: .default, handler: { (action) in
                self.dataArray[sourceIndex] = textView.text
                tableView.reloadRows(at: [index], with: .right)
            })
            alert.addAction(cancelAction)
            alert.addAction(okAction)
  
            self.parentVC?.present(alert, animated: true, completion: {
                
            })
        }
        
        let moveAction = UITableViewRowAction(style: .normal, title: "向上") { (action, index) in
            let sourceIndex = indexPath.row
            if sourceIndex == 0 { return }
            let destinationIndex = sourceIndex - 1
            let object = self.dataArray[sourceIndex]
            self.dataArray.remove(at: sourceIndex)
            self.dataArray.insert(object, at: destinationIndex)
            let toIndexPath = IndexPath(row: destinationIndex, section: 0)
            tableView.moveRow(at: indexPath, to: toIndexPath)
            tableView.setEditing(false, animated: true)
        }
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "删除") { (action, index) in
            self.dataArray.remove(at: index.row)
            tableView.deleteRows(at: [index], with: .fade)
        }
        
        reNameAction.backgroundColor = UIColor.colorWithHexString("62d9a0")
        moveAction.backgroundColor = UIColor.colorWithHexString("feba6a")
        deleteAction.backgroundColor = UIColor.colorWithHexString("f45e5e")
        return [deleteAction, moveAction, reNameAction]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CourceMainTableViewCell = dequeueReusableCell(withIdentifier: kMainCellId, for: indexPath) as! CourceMainTableViewCell
        cell.titleLable.text = dataArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        parentVC?.pushCourseDetailVC()
    }
    
}
