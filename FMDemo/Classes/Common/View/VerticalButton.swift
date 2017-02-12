//
//  QSImgTitleButton.swift
//  ban
//
//  Created by mba on 16/8/9.
//  Copyright © 2016年 mbalib. All rights reserved.
//

// image与title 上下居中

import UIKit

class VerticalButton: UIButton {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }
    
    func setUI() {
        titleLabel?.font = UIFont.systemFont(ofSize: 13)
        titleLabel?.textColor = UIColor.lightGray
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        titleLabel?.frame.origin.x = 0
//        imageView?.frame.origin.x = titleLabel!.frame.size.width
//        imageView?.center.x = center.x
//        imageView?.snp_makeConstraints(closure: { (make) in
//            let sizeWH = 20
//            make.size.equalTo(CGSize(width: sizeWH, height: sizeWH))
//            make.centerX.equalTo(self)
//        })
        let sizeWH: CGFloat = 30
        imageView?.frame = CGRect(x: 0, y: 2, width: sizeWH, height: sizeWH)
        imageView?.center = (titleLabel?.center)!
        titleLabel?.frame.origin.y = imageView!.frame.size.height + 5
    }
    
}
