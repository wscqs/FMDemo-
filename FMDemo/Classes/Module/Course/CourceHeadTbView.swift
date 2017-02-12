//
//  CourceHeadTbView.swift
//  FMDemo
//
//  Created by mba on 17/2/9.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit

class CourceHeadTbView: UIView {
    
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
        textView.setPlaceholder(kCreatTitleString, maxTip: 50)
        
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
        tbHeadChangceView.isHidden = true
        titleLabel.text = textView.text
        endEditing(true)
    }



}

extension CourceHeadTbView {

}
