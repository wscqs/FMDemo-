//
//  RecordImgCollectionCell.swift
//  testColl
//
//  Created by mba on 17/2/13.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit

protocol RecordImgCollectionCellDelegate: NSObjectProtocol{
    func actionDel(recordImgCollectionCell: UICollectionViewCell)
}

class RecordImgCollectionCell: UICollectionViewCell {
    
    weak var delegate: RecordImgCollectionCellDelegate?
    
    var recordImgModel: RecordImgModel? {
        didSet{
            guard let recordImgModel = recordImgModel else { return }
            imgView.image = recordImgModel.img
            grayMaskView.isHidden = !recordImgModel.isTapStatus!
            delBtn.isHidden = !recordImgModel.isEditStatus!
        }
    }
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var grayMaskView: UIView!
    @IBOutlet weak var delBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        delBtn.addTarget(self, action: #selector(actionDel), for: .touchUpInside)
    }
    
    
    func actionDel() {
        delegate?.actionDel(recordImgCollectionCell: self)
    }
    
}

class RecordImgModel {
    var img: UIImage?
    var isTapStatus: Bool? = false
    var isEditStatus: Bool? = false
    
    init(img: UIImage, isTapStatus: Bool? = false, isEditStatus: Bool? = false) {
        self.img = img
        self.isTapStatus = isTapStatus!
        self.isEditStatus = isEditStatus!
    }
}
