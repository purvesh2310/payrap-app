//
//  PayRapTableUtility.swift
//  PayRap
//
//  Created by Purvesh Kothari on 5/12/17.
//  Copyright © 2017 Purvesh Kothari. All rights reserved.
//

import Foundation
import UIKit

class PayRapTableUtility{
    
    func displayTableEmptyMessage(tableView:UITableView, message:String) {
        
        let messageLabel = UILabel(frame: CGRect(0,0,tableView.bounds.size.width, tableView.bounds.size.height))
       
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        
        messageLabel.sizeToFit()
        
        tableView.backgroundView = messageLabel;
        tableView.separatorStyle = .none;
    }

}
