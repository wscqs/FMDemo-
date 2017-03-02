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
    var webView = WKWebView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - NAVIGATION_AND_STATUSBAR_HEIGHT ))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "播放章节"
        view.addSubview(webView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let url = url,
        let accesToken = KeUserAccount.shared?.accessToken else {
            return
        }
        let urlString = "\(url)&access_token=\(accesToken)"
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
        MBAProgressHUD.show()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        MBAProgressHUD.dismiss()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        MBAProgressHUD.dismiss()
        MBAProgressHUD.showErrorWithStatus("网络异常")
    }
}
