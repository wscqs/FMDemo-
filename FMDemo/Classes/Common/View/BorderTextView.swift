//
//  QSTextView.swift
//  ban
//
//  Created by mba on 16/7/22.
//  Copyright © 2016年 mbalib. All rights reserved.
//

//编辑页与用户提问页的TextView
import UIKit
import Foundation


//http://www.cnblogs.com/xiaofeixiang/p/4509665.html?utm_source=tuicool&utm_medium=referral oc 版


let padding: CGFloat = 8
class BorderTextView: UITextView {

    func setPlaceholder(_ placeholder: String, maxTip: Int) {
        text = ""
        placeholderLabel.text = placeholder
        maxTipLength = maxTip
        textChanged()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        setUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }
    
    func setUI() {
        
        setParam()
        
        addSubview(placeholderLabel)
//        addSubview(tipLabel)
        font = UIFont.systemFont(ofSize: 14)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BorderTextView.textChanged), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let tipLabelW: CGFloat = 40
        tipLabel.frame = CGRect(x: self.width - tipLabelW, y: self.height - 20 , width: tipLabelW, height: 10)
        placeholderLabel.frame = CGRect(x: padding + 1, y: padding, width: self.width - padding * 2, height: self.height)
        placeholderLabel.sizeToFit()
    }

    
    func setParam() { 
        
        textContainerInset = UIEdgeInsets(top: padding , left: padding, bottom: 0, right: padding-2)
        
        text = ""
        layer.cornerRadius = 10
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.colorWithHexString("e2e5e8").cgColor
//        backgroundColor = UIColor.colorWithHexString("f3f5fa")
    }
    
    override var text: String!{
        didSet{
            textChanged()
        }
    }
    
    fileprivate lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.colorWithHexString("a8a7a7")
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.lightGray
        label.text = "\(self.maxTipLength)/\(self.maxTipLength)"
        label.sizeToFit()
        return label
    }()
    
    
    var maxTipLength = 10
    @objc fileprivate func textChanged() {
        placeholderLabel.isHidden = self.hasText
        
        // 当前已经输入的内容长度
        let count = self.text.characters.count
        let res = maxTipLength - count
        
        if res >= 0 {
            tipLabel.textColor = UIColor.lightGray
            tipLabel.text = "\(res)/\(maxTipLength)"
        }else {
            text = (text as NSString).substring(to: maxTipLength)
            tipLabel.text = "0/\(maxTipLength)"
//            tipLabel.textColor = UIColor.redColor()
        }
    }
    
    
    var clearBorder: Bool? {
        didSet{
            if clearBorder ?? false {
                layer.borderWidth = 0
                layer.borderColor = UIColor.clear.cgColor
            }            
        }
    }
    
}
