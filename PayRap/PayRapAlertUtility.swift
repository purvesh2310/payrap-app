//
//  PayRapAlertUtility.swift
//  PayRap
//
//  Created by Purvesh Kothari on 5/9/17.
//  Copyright © 2017 Purvesh Kothari. All rights reserved.
//

import UIKit

class PayRapAlertUtility{

    func displayAlertWithMessage(viewController: UIViewController, errorMsg: String?) {
    
        let alertController = UIAlertController(title: "Error", message: errorMsg, preferredStyle: .alert)
    
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
    
        viewController.present(alertController, animated: true, completion: nil)
    
    }

}
