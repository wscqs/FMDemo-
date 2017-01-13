//
//  SeletceDubViewController.swift
//  FMDemo
//
//  Created by mba on 17/1/13.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit

class SeletceDubViewController: UITableViewController {
    
    var selectDubURLBlock: ((URL) -> Void)?
    
    var dubURLArray = [Bundle.main.url(forResource: "节奏1", withExtension: "caf")!,
                       Bundle.main.url(forResource: "节奏2", withExtension: "caf")!]
    
    var titleNameArray = [String]()
  
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "增加配乐"
        tableView.delegate = self
        tableView.dataSource = self
        
        for dubURL in dubURLArray {
            titleNameArray.append(dubURL.lastPathComponent.components(separatedBy: ".").first!)
        }
    }

}


extension SeletceDubViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleNameArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleNameArray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectDubURLBlock?(dubURLArray[indexPath.row])
        
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectDubURL"), object: nil, userInfo: ["selectDubURL": dubURLArray[indexPath.row]])
        _ = navigationController?.popViewController(animated: true)
    }
}
