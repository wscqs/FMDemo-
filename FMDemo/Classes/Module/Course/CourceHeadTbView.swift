//
//  CourceHeadTbView.swift
//  FMDemo
//
//  Created by mba on 17/2/9.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit

//protocol CourceHeadTbViewDelegate: NSObjectProtocol{
//    func clickOKChangceTitle(courceHeadTbView: CourceHeadTbView, title: String)
//}

class CourceHeadTbView: UIView {
    
//    weak var delegate: CourceHeadTbViewDelegate?
    var cid: String!
    
    @IBOutlet weak var tbHeadNormalView: BorderBackgroundView!
    @IBOutlet weak var tbHeadChangceView: BorderBackgroundView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var courceStatusLabel: UILabel!
    @IBOutlet weak var changceBtn: UIView!
    @IBOutlet weak var textView: BorderTextView!
    @IBOutlet weak var okBtn: UIButton!
    
    class func courceHeadTbView() -> CourceHeadTbView {
        let view: CourceHeadTbView = Bundle.main.loadNibNamed("CourceHeadTbView", owner: self, options: nil)!.last as! CourceHeadTbView
        view.frame.size.width = SCREEN_WIDTH
        view.backgroundColor = UIColor.colorWithHexString(kGlobalBgColor)
        return view
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        setupUI()
    }
    
    override func awakeFromNib() {
        superview?.awakeFromNib()
        
        tbHeadChangceView.isHidden = true
//        setupUI()
        textView.setPlaceholder(kCreatCourceTitleString, maxTip: 50)
        
        changceBtn.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(actionChangce(_:)))
        changceBtn.addGestureRecognizer(tapGes)        
    }

    func actionChangce(_ sender: UIView) {
        textView.clearBorder = true
        tbHeadChangceView.isHidden = false
        textView.text = titleLabel.text
    }
    
    @IBAction func actionOk(_ sender: UIButton) {
        
        if textView.text.isEmpty {
            MBAProgressHUD.showInfoWithStatus("课程标题不能为空")
            return
        }
        if titleLabel.text != textView.text {
            KeService.actionSaveCourse(title: textView.text, cid: cid, success: { (bean) in
                self.titleLabel.text = self.textView.text
                self.tbHeadChangceView.isHidden = true
            }) { (error) in
                MBAProgressHUD.showInfoWithStatus("课程标题修改失败，请重试")
                self.tbHeadChangceView.isHidden = true
            }
        } else {
            self.tbHeadChangceView.isHidden = true
        }
        endEditing(true)
    }

}

