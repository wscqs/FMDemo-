//
//  AvatorView.swift
//  ban
//
//  Created by mba on 16/7/11.
//  Copyright © 2016年 mbalib. All rights reserved.
//

// 用户头像
import UIKit
import SnapKit

protocol AvatorViewDelegate: NSObjectProtocol{
    func avatorViewClick(_ avatorView: UIView)
}

class AvatorView: UIView {

    weak var delegate: AvatorViewDelegate?
    
    func setAvator(_ avatorString: String) {
        AvatorImg.qs_setImageFromUrl(avatorString, isAvatar: true)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setUI()
    }

    func setUI() {
        backgroundColor = UIColor.clear
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AvatorView.avatorClick))
        self.addGestureRecognizer(tapGestureRecognizer)
        addSubview(AvatorImg)
        addSubview(AutoImg)
//        AvatorImg.image = UIImage(named: "avator3")
//        AutoImg.image = UIImage(named: "vico")
        
        AvatorImg.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        AutoImg.snp.makeConstraints { (make) in
            make.right.bottom.equalTo(self)
            make.width.equalTo(self.width * 0.3)
            make.height.equalTo(self.height * 0.3)
        }
        layoutIfNeeded()
        
//        AvatorImg.contentMode = UIViewContentMode.scaleAspectFit
//        AvatorImg.layer.cornerRadius = AvatorImg.width/2
//        AvatorImg.layer.masksToBounds = true
//        
//        AutoImg.contentMode = UIViewContentMode.scaleAspectFit
//        AutoImg.layer.cornerRadius = AutoImg.width/2
//        AutoImg.layer.masksToBounds = true
//        
//        //性能优化
//        AvatorImg.layer.shouldRasterize = true
//        AvatorImg.layer.rasterizationScale = UIScreen.main.scale
//        AutoImg.layer.shouldRasterize = true
//        AutoImg.layer.rasterizationScale = UIScreen.main.scale
        
        
        AutoImg.isHidden = true
        
//        AvatorImg.qs_setImageFromUrl("http://www.iteye.com/upload/logo/user/242845/a2af50a4-5a72-36d4-844b-6c9f2758aa9e.jpg")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    lazy var AvatorImg: UIImageView = UIImageView()
    lazy var AutoImg: UIImageView = UIImageView()
    
    
    func avatorClick() {
        delegate?.avatorViewClick(self)
//        print("点击头像")
   
    }

}
