//
//  RecordSoundSliderView.swift
//  FMDemo
//
//  Created by mba on 17/2/14.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit

class RecordSoundSliderView: UISlider {
    
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
        setMinimumTrackImage(#imageLiteral(resourceName: "sound_slidervolume_gray90").resizableImage(withCapInsets: .zero), for: .normal)
        setMaximumTrackImage(#imageLiteral(resourceName: "sound_slidervolume_blue90").resizableImage(withCapInsets: .zero), for: .normal)
        setThumbImage(#imageLiteral(resourceName: "sound_slider_thum"), for: .normal)
        isUserInteractionEnabled = false
        value = 0
        transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
    }
}
