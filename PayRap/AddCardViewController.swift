//
//  AddCardViewController.swift
//  PayRap
//
//  Created by Purvesh Kothari on 4/27/17.
//  Copyright © 2017 Purvesh Kothari. All rights reserved.
//

import UIKit
import RealmSwift

class AddCardViewController: UIViewController{
    
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var expiryDateTextField: UITextField!
    @IBOutlet weak var cardhoderNameTextField: UITextField!
    @IBOutlet weak var ccvTextField: UITextField!
    
    override func viewDidLoad() {
        
        self.title = "Add New Card"
       
        addBottomBorderForTextField(textField: cardNumberTextField)
        addBottomBorderForTextField(textField: expiryDateTextField)
        addBottomBorderForTextField(textField: cardhoderNameTextField)
        addBottomBorderForTextField(textField: ccvTextField)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(saveCreditCardInformation(sender:)))
        navigationItem.rightBarButtonItem = button
        
        view.addGestureRecognizer(tap)
        
    }
    
    // Saving credit card information in local Realm database
    func saveCreditCardInformation(sender: UIBarButtonItem){
        
        let creditCardNumber = cardNumberTextField.text
        let expiryMonth = expiryDateTextField.text
        let expiryYear = cardhoderNameTextField.text
        let ccv = ccvTextField.text
        
        let creditCard = CreditCard()
        
        if (creditCardNumber != nil){
            creditCard.creditCardNumber = creditCardNumber!
        }
        
        if (expiryMonth != nil){
            creditCard.expiryMonth = expiryMonth!
        }
        
        if (expiryYear != nil){
            creditCard.expiryYear = expiryYear!
        }
        
        if(ccv != nil){
            creditCard.ccv = ccv!
        }
        
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(creditCard)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func addBottomBorderForTextField(textField: UITextField){
        
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(0.0, textField.frame.height-1, textField.frame.width, 0.4)
        bottomBorder.backgroundColor = UIColor(red:0.82, green:0.84, blue:0.85, alpha:1.0).cgColor
        textField.layer.addSublayer(bottomBorder)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
