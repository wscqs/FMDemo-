//
//  BorderBackgroundView.swift
//  FMDemo
//
//  Created by mba on 17/2/10.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit

class BorderBackgroundView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        setupUI()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    
    fileprivate func setupUI() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0.1
        
//                layer.shadowColor = UIColor.gray.cgColor
//                layer.shadowOffset = CGSize(width: 1, height: 1)
//                layer.shadowRadius = 5
//                layer.shadowOpacity = 0.8
    }
    
    override func layoutSubviews() {
        setupUI()
    }

}
