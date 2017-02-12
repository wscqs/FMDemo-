//
//  BaseSrollView.swift
//  ban
//
//  Created by mba on 16/7/18.
//  Copyright © 2016年 mbalib. All rights reserved.
//

import UIKit

class BaseSrollView: UIScrollView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setDefaultUI()
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setDefaultUI() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        isPagingEnabled = true
        bounces = false
    }
    
    func setUI() {
        
    }
    
    func updateUI() {
        
    }
    
}
