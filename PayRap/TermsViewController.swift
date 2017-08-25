//
//  TermsViewController.swift
//  PayRap
//
//  Created by Purvesh Kothari on 5/14/17.
//  Copyright © 2017 Purvesh Kothari. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController{
    
    @IBOutlet weak var webView: UIWebView!
   
    override func viewDidLoad() {
        webView.loadRequest(URLRequest(url: URL(string: "http://thepk.xyz/privacy.html")!))
    }
}
