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
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
        layoutIfNeeded()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
        layoutIfNeeded()
    }
    
    func setUI() {
        self.frame = bounds
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel?.textColor = UIColor.lightGray
        adjustsImageWhenHighlighted = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let sizeWH: CGFloat = 40
        imageView?.frame = CGRect(x: 0, y: 2, width: sizeWH, height: sizeWH)
        imageView?.center = (titleLabel?.center)!
        titleLabel?.frame.origin.y = imageView!.frame.size.height + 0
    }
}
