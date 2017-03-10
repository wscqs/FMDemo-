//
//  RecordImgCollectionView.swift
//  FMDemo
//
//  Created by mba on 17/2/13.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit
import ZLPhotoBrowser

class RecordImgCollectionView: UICollectionView {

    var recordImgArray: [RecordImgModel]? = [RecordImgModel]()

    var isEidtStatus: Bool = false {
        didSet {
            if (recordImgArray?.count ?? 0) <= 0 {
                return
            }
            var newArray = [RecordImgModel]()
            for model in recordImgArray! {
                model.isEditStatus = isEidtStatus
                newArray.append(model)
            }
            recordImgArray = newArray
            reloadData()
        }
    }
    
    var parentVC: RecordViewController?
    var mid: String!
    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
        dataSource = self
        showsHorizontalScrollIndicator = false
        bounces = false
    }
    

    @IBAction func actionChoseImg(_ sender: UIButton) {
        parentVC?.pauseRecord()
        choseImg()
    }
}

extension RecordImgCollectionView: RecordImgCollectionCellDelegate {
    func actionDel(recordImgCollectionCell: UICollectionViewCell) {
        let indexPath = self.indexPath(for: recordImgCollectionCell)
        guard let row = indexPath?.row else {
            return
        }
        self.recordImgArray?.remove(at: row)
        reloadData()
    }
    
    
    func actionResaveWidModel(recordImgCollectionCell: UICollectionViewCell, recordImgModel: RecordImgModel) {
        let indexPath = self.indexPath(for: recordImgCollectionCell)
        guard let row = indexPath?.row else {
            return
        }
        self.recordImgArray?.remove(at: row)
        self.recordImgArray?.insert(recordImgModel, at: row)
//        reloadData()
    }
}

extension RecordImgCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recordImgArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionId", for: indexPath) as? RecordImgCollectionCell
        cell?.mid = self.mid
        cell?.delegate = self
        cell?.recordImgModel = recordImgArray?[indexPath.row]
        
        let longGes = UILongPressGestureRecognizer(target: self, action: #selector(actionLongGes))
        cell?.addGestureRecognizer(longGes)

        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "colleFootId", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {       

        /// 是否已经成功上传服务器
        let model = recordImgArray?[indexPath.row]
        if model?.wid?.isEmpty ?? true{
            let cell = collectionView.cellForItem(at: indexPath) as! RecordImgCollectionCell
            cell.actionUploadPicture()
            return
        }
        
        /// 录音状态才能上屏
        if (parentVC?.recordBtn.isSelected ?? true) {
            return
        }
        
        // 保存图片点击状态
        parentVC?.saveImgClick(image: (model?.img)! , wid: (model?.wid) ?? "")

        var newRecordImgArray = [RecordImgModel]()
        for newModel in recordImgArray! {
            if newModel.imgStatus == ImgStatus.selctor {
                newModel.imgStatus = ImgStatus.pageup
            }
            newRecordImgArray.append(newModel)
        }
        model?.imgStatus = ImgStatus.selctor
        
        let cell = collectionView.cellForItem(at: indexPath) as! RecordImgCollectionCell
        cell.recordImgModel = model
        recordImgArray?[indexPath.row] = model!

        reloadData()
    }
}

extension RecordImgCollectionView {
    func actionLongGes(sender: UILongPressGestureRecognizer) {
        isEidtStatus = true
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(actionTap))
        parentVC?.view.addGestureRecognizer(tapGes)
    }
    
    func actionTap(sender: UITapGestureRecognizer) {
        
        isEidtStatus = false
        parentVC?.view.removeGestureRecognizer(sender)
    }

}

extension RecordImgCollectionView {
    //选择图片
    func choseImg() {
        let choseImg = ZLPhotoActionSheet()
        choseImg.showPhotoLibrary(withSender: self.parentVC!, last: nil) { (imageArray: [UIImage], selctpotoModelArray: [ZLSelectPhotoModel]) in
            for image in imageArray {
                let model = RecordImgModel(img: image, wid: nil, isRequestUpload: true, isTapStatus: false, isEditStatus: false)
                self.recordImgArray?.append(model)
                self.reloadData()
            }
        }
    }
}
