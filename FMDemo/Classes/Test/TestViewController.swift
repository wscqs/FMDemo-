//
//  TestViewController.swift
//  FMDemo
//
//  Created by mba on 17/2/6.
//  Copyright © 2017年 mbalib. All rights reserved.
//

//lazyvarengine =AVAudioEngine()
//
//overridefuncviewDidLoad() {
//    
//    super.viewDidLoad()
//    
//    letinput =engine.inputNode!
//    
//    letoutput =engine.outputNode
//    
//    engine.connect(input, to: output, format: input.inputFormatForBus(0))
//    
//    try!engine.start()
//    
//}
import UIKit
import AVFoundation

class TestViewController: UIViewController {
    
    lazy var engine = AVAudioEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let input = engine.inputNode
        let output = engine.outputNode
        engine.connect(input!, to: output, format: input?.inputFormat(forBus: .allZeros))
        try? engine.start()
    }
}
