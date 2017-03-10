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
    
    // 进度条
    lazy var progressView:UIProgressView = {
        let progress = UIProgressView()
        progress.progressTintColor = UIColor.green
        progress.trackTintColor = .clear
        return progress
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        view.addSubview(webView)
        webView.backgroundColor = UIColor.colorWithHexString(kGlobalBgColor)
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        view.addSubview(self.progressView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(requst))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isMaterial ?? true {
            title = "播放章节"
        } else {
            title = "播放课程"
        }
        requst()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    /// 请求
    @objc fileprivate func requst() {
        self.progressView.frame = CGRect(x:0,y:0,width:self.view.frame.size.width,height:3)
        self.progressView.alpha = 1
        self.progressView.setProgress(0.1, animated: true)
        KeService.actionAccessToken({ (isSucess) in
            self.webRequst()
        }) { (error) in
            self.progressView.alpha = 0.0
//            MBAProgressHUD.showErrorWithStatus("加载失败，请重试")
        }
    }
    
    fileprivate func webRequst() {
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
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {        
        if keyPath == "estimatedProgress" {
            let progress = change![NSKeyValueChangeKey.newKey] as! Float
            if progress >= 1.0 {
                self.progressView.setProgress(progress, animated: true)
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseInOut, animations: {
                    self.progressView.alpha = 0.0
                }, completion: { (_) in
                    self.progressView.setProgress(0.0, animated: false)
                })
            }else {
                self.progressView.alpha = 1.0
                self.progressView.setProgress(progress, animated: true)
            }
        }
    }
}

extension PlayCourceMaterialViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        MBAProgressHUD.dismiss()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//        MBAProgressHUD.dismiss()
        MBAProgressHUD.showErrorWithStatus("加载失败，请重试")
    }
}
