//
//  RecordImgCollectionView.swift
//  FMDemo
//
//  Created by mba on 17/2/13.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit

class RecordImgCollectionView: UICollectionView {

    var recordImgArray: [RecordImgModel]? = [RecordImgModel](){
        didSet{
            reloadData()
        }
    }
    
//    let recordImg1Array: [RecordImgModel] = {
//        let recordImg1 = RecordImgModel(img: #imageLiteral(resourceName: "new_feature_1"), isTapStatus: false, isEditStatus: false)
//        let recordImg2 = RecordImgModel(img: #imageLiteral(resourceName: "new_feature_2"), isTapStatus: false, isEditStatus: false)
//        let recordImg3 = RecordImgModel(img: #imageLiteral(resourceName: "new_feature_3"), isTapStatus: false, isEditStatus: false)
//        return [recordImg1, recordImg2, recordImg3]
//    }()

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
    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
        dataSource = self
        showsHorizontalScrollIndicator = false
        bounces = false
    }
    

    @IBAction func actionChoseImg(_ sender: UIButton) {
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
        deleteItems(at: [indexPath!])
    }
}

extension RecordImgCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recordImgArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionId", for: indexPath) as? RecordImgCollectionCell
        cell?.recordImgModel = recordImgArray?[indexPath.row]
        
        let longGes = UILongPressGestureRecognizer(target: self, action: #selector(actionLongGes))
        longGes.minimumPressDuration = 1
        cell?.addGestureRecognizer(longGes)
        
        cell?.delegate = self
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "colleFootId", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = recordImgArray?[indexPath.row]
        // 保存图片点击状态
        parentVC?.saveImgClick(image: (model?.img)!)
        model?.isTapStatus = true
        let cell = collectionView.cellForItem(at: indexPath) as! RecordImgCollectionCell
        cell.recordImgModel = model
        recordImgArray?[indexPath.row] = model!
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

extension RecordImgCollectionView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //选择图片
    func choseImg() {
        isEidtStatus = false
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        self.parentVC?.present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //相册中还可能是视频，所以这里需要判断选择的是不是图片
        let type: String = (info[UIImagePickerControllerMediaType] as! String)        
        //当选择的类型是图片
        if type == "public.image"
        {
            //修正图片的位置
//            let image = (info[UIImagePickerControllerEditedImage] as! UIImage).fixOrientation()
            let image = (info[UIImagePickerControllerEditedImage] as! UIImage)
            picker.dismiss(animated: true, completion: nil)
            let model = RecordImgModel(img: image, isTapStatus: false, isEditStatus: false)
            recordImgArray?.append(model)
            reloadData()
          
            //先把图片转成NSData
            //            let data = UIImageJPEGRepresentation(image, 0.5)
            //图片保存的路径
            //这里将图片放在沙盒的documents文件夹中
            //            let DocumentsPath:String = NSHomeDirectory().stringByAppendingString("Documents")
            //
            //            //文件管理器
            //            let fileManager = NSFileManager.defaultManager()
            //
            //            //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
            //            try! fileManager.createDirectoryAtPath(DocumentsPath, withIntermediateDirectories: true, attributes: nil)
            //            fileManager.createFileAtPath(DocumentsPath + "/image.png", contents: data, attributes: nil)
            //
            //            //得到选择后沙盒中图片的完整路径
            //            let filePath = DocumentsPath + "/image.png"
            //利用Alamofire的表单提交来上传图片
            //            Alamofire.upload(.POST, "http://192.168.3.16:9060/client/updateHeadUrl", multipartFormData: { multipartFormData in
            //
            //                multipartFormData.appendBodyPart(data: data!, name: "image")
            //                }, encodingCompletion: { response in
            //                    picker.dismissViewControllerAnimated(true, completion: nil)
            //                    switch response {
            //                    case .Success(let upload, _, _):
            //                        upload.responseJSON(completionHandler: { (response) in
            //                            print(response)
            //                        })
            //                    case .Failure(let encodingError):
            //                        print(encodingError)
            //                    }
            //
            //            })
        }
    }
}
