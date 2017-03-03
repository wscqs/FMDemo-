//
//  PlayCourceMaterialViewController.swift
//  FMDemo
//
//  Created by mba on 17/3/2.
//  Copyright © 2017年 mbalib. All rights reserved.
//

import UIKit
import WebKit

class PlayCourceMaterialViewController: UIViewController {

    var url: String? = ""
    var isMaterial: Bool? = true // 区分播放课程与课程章节
    var webView = WKWebView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - NAVIGATION_AND_STATUSBAR_HEIGHT ))
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        view.addSubview(webView)
        webView.scrollView.showsVerticalScrollIndicator = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isMaterial ?? true {
            title = "播放章节"
        } else {
            title = "播放课程"
        }
        MBAProgressHUD.show()
        KeService.actionAccessToken({ (isSucess) in
            self.requst()
        }) { (error) in
            MBAProgressHUD.dismiss()
            MBAProgressHUD.showErrorWithStatus("请后退重新进入")
        }
    }
    
    func requst() {
        guard let url = url,
            let accesToken = KeUserAccount.shared?.accessToken else {
                return
        }
        var urlString = ""
         if isMaterial ?? true {
            urlString = "\(url)&access_token=\(accesToken)"
        } else {
            urlString = "\(url)?access_token=\(accesToken)"
        }
        
        print(urlString)
        let requestURL = URL(string: urlString )
        let request = URLRequest(url: requestURL!)
        webView.load(request)
        webView.navigationDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension PlayCourceMaterialViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        MBAProgressHUD.dismiss()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        MBAProgressHUD.dismiss()
        MBAProgressHUD.showErrorWithStatus("网络异常")
    }
}
