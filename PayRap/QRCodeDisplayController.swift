//
//  QRCodeDisplayController.swift
//  PayRap
//
//  Created by Purvesh Kothari on 5/14/17.
//  Copyright © 2017 Purvesh Kothari. All rights reserved.
//

import UIKit
import QRCode

class QRCodeDisplayController: UIViewController{
    
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    override func viewDidLoad() {
        
        self.title = "QR Code"
        
        let defaults = UserDefaults.standard
        let senderEmailAddress = defaults.string(forKey: "email")

        qrCodeImageView.image = {
            var qrCode = QRCode(senderEmailAddress!)!
            qrCode.size = self.qrCodeImageView.bounds.size
            qrCode.errorCorrection = .High
            return qrCode.image
        }()
    }
}
