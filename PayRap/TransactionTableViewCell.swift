//
//  TransactionTableViewCell.swift
//  PayRap
//
//  Created by Purvesh Kothari on 5/12/17.
//  Copyright © 2017 Purvesh Kothari. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell{
    
    @IBOutlet weak var amountLabel: UILabel!

    @IBOutlet weak var transactionHeadingLabel: UILabel!

    @IBOutlet weak var transactionNoteLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
}
