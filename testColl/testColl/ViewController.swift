//
//  ViewController.swift
//  testColl
//
//  Created by mba on 17/2/13.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var showImgView: UIImageView!
    @IBOutlet weak var collectionView: RecordImgCollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        collectionView.parentVC = self
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension ViewController: UIGestureRecognizerDelegate {
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        print(touch.view.debugDescription)
//        if (touch.view?.isKind(of: UICollectionViewCell.self))! {
//            return false
//        }
//        return true
//    }
}

