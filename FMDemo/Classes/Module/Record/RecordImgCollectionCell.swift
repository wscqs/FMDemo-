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
    func actionResaveWidModel(recordImgCollectionCell: UICollectionViewCell,recordImgModel: RecordImgModel)
}

class RecordImgCollectionCell: UICollectionViewCell {
    
    weak var delegate: RecordImgCollectionCellDelegate?
    var mid: String!
    
    var recordImgModel: RecordImgModel? {
        didSet{
            guard let recordImgModel = recordImgModel else { return }
            imgView.image = recordImgModel.img
            grayMaskView.isHidden = !recordImgModel.isTapStatus!
            delBtn.isHidden = !recordImgModel.isEditStatus!

            if recordImgModel.isRequestUpload ?? true{ // 上传
                actionUploadPicture()
            }
            if !(recordImgModel.wid?.isEmpty ?? true){
                self.activityIndicatorView.isHidden = true
            } else {
                self.activityIndicatorView.isHidden = false
            }
        }
    }
    
    func actionUploadPicture() {
        activityIndicatorView.startAnimating()
        let data = UIImageJPEGRepresentation((recordImgModel?.img!)!, 0.8)
        KeService.actionUploadPicture(mid: self.mid, file: data!, success: { (bean) in
            self.recordImgModel?.wid = bean.wid
            self.recordImgModel?.isRequestUpload = false
            self.activityIndicatorView.isHidden = true
            self.delegate?.actionResaveWidModel(recordImgCollectionCell: self, recordImgModel: self.recordImgModel!)
        }, failure: { (error) in
            self.recordImgModel?.isRequestUpload = false
            self.activityIndicatorView.stopAnimating()
        })
    }
    
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var grayMaskView: UIView!
    @IBOutlet weak var delBtn: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
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
    var wid: String? // 图片id，id为空，说明未上传
    var isRequestUpload: Bool? = true // 图片是否上传(true要求上传，false 不是上传状态）
    var isTapStatus: Bool? = false // 点击上屏状态
    var isEditStatus: Bool? = false // 编辑状态，出现删除
    
    
    init(img: UIImage, wid: String? = "",isRequestUpload: Bool? = true, isTapStatus: Bool? = false, isEditStatus: Bool? = false) {
        self.img = img
        self.wid = wid
        self.isRequestUpload = isRequestUpload
        self.isTapStatus = isTapStatus!
        self.isEditStatus = isEditStatus!
    }
}
