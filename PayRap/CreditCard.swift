//
//  CreditCard.swift
//  PayRap
//
//  Created by Purvesh Kothari on 5/2/17.
//  Copyright © 2017 Purvesh Kothari. All rights reserved.
//

import Foundation
import RealmSwift

class CreditCard: Object {
    
    dynamic var creditCardNumber = ""
    dynamic var expiryMonth = ""
    dynamic var expiryYear = ""
    dynamic var ccv = ""
}
