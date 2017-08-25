//
//  Transaction.swift
//  PayRap
//
//  Created by Purvesh Kothari on 5/11/17.
//  Copyright © 2017 Purvesh Kothari. All rights reserved.
//

import Foundation

class Transaction{
    
    //MARK: Properties
    
    var senderEmail: String
    var receiverEmail: String
    var senderName: String
    var receiverName: String
    var amount: Float
    var createDate: NSDate
    var type: Int
    var note: String
    
    init(senderEmail: String, receiverEmail: String, senderName: String, receiverName: String, amount: Float, createDate: NSDate, type: Int, note: String) {
        self.senderEmail = senderEmail
        self.receiverEmail = receiverEmail
        self.senderName = senderName
        self.receiverName = receiverName
        self.amount = amount
        self.createDate = createDate
        self.type = type
        self.note = note
    }
    
}
