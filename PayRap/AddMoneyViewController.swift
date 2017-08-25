//
//  AddMoneyViewController.swift
//  PayRap
//
//  Created by Purvesh Kothari on 5/10/17.
//  Copyright © 2017 Purvesh Kothari. All rights reserved.
//

import UIKit
import RealmSwift
import Braintree
import Firebase

class AddMoneyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var savedCardsTableView: UITableView!
    @IBOutlet weak var amountTextField: UITextField!

    var cards: Results<CreditCard>? = nil
    var ref: FIRDatabaseReference!
    var tableUtility: PayRapTableUtility?
    var selectedCard: CreditCard?
    
    override func viewDidLoad() {
        
        let realm = try! Realm()
        cards = realm.objects(CreditCard.self)
        
        if cards?.count == 0 {
            let button = UIBarButtonItem(image: UIImage(named:"add-card"), style: .plain, target: self, action: #selector(goToManageCards(sender:)))
            navigationItem.rightBarButtonItem = button
            
        } else {
            let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(addMoney(sender:)))
            navigationItem.rightBarButtonItem = button
        }
        
        tableUtility = PayRapTableUtility()
        
        savedCardsTableView.delegate = self
        savedCardsTableView.dataSource = self
        savedCardsTableView.tableFooterView = UIView()
        
        ref = FIRDatabase.database().reference()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "savedCardItem", for: indexPath) as! AddMoneyTableViewCell
        
        if let cardNumber = cards?[indexPath.row].creditCardNumber {
            
            let lastFourDigits = cardNumber.substring(from:cardNumber.index(cardNumber.endIndex, offsetBy: -4))
            
            cell.cardDetailLabel?.text = "Card ending in " + lastFourDigits
        }
        
        cell.checkmarkImageView.isHidden = true
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        let noOfCardStored: Int = (cards?.count)!
        
        if(noOfCardStored > 0){
            return 1
        }else {
            tableUtility?.displayTableEmptyMessage(tableView: savedCardsTableView, message: "You don't have any card saved yet.\nPlease save card information to get started.")
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let noOfCardStored: Int = (cards?.count)!
        return noOfCardStored;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCard = cards?[indexPath.row]
        let currentCell = tableView.cellForRow(at: indexPath) as! AddMoneyTableViewCell
        currentCell.checkmarkImageView.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! AddMoneyTableViewCell
        currentCell.checkmarkImageView.isHidden = true
    }

    func addMoney(sender: UIBarButtonItem){
        
        let utility = PayRapAlertUtility()
        
        if let userSpecifiedAmount = amountTextField.text{
            
            if userSpecifiedAmount.characters.count == 0 {
                utility.displayAlertWithMessage(viewController: self, errorMsg: "Please enter amount to add money.")
            } else {
                submitAmountToPaymentGateway(amount: userSpecifiedAmount)
            }
        } else{
            utility.displayAlertWithMessage(viewController: self, errorMsg: "Please enter amount to add money.")
        }
        
    }
    
    func goToManageCards(sender: UIBarButtonItem){
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        let resultViewController = storyBoard.instantiateViewController(withIdentifier: "manageCardController") as! ManageCardViewController
        
        self.navigationController?.pushViewController(resultViewController, animated: true)
        
    }
    
    // Braintree Transaction Implementation
    func submitAmountToPaymentGateway(amount: String) {
        
        let tokenKey = "sandbox_xnnhdtpz_4ndfbsn6rp985yns"
        let braintreeClient = BTAPIClient(authorization: tokenKey)
        let cardClient = BTCardClient(apiClient: braintreeClient!)
        
        let cardNumber: String! = selectedCard?.creditCardNumber
        let expirationMonth: String! = selectedCard?.expiryMonth
        let expirationYear: String! =  selectedCard?.expiryYear
        let cvv: String? = selectedCard?.ccv
    
        let card = BTCard(number: cardNumber, expirationMonth: expirationMonth, expirationYear: expirationYear, cvv: cvv)
        cardClient.tokenizeCard(card) { (tokenizedCard, error) in

            let bodyData = "nonce=" + (tokenizedCard?.nonce)! + "&" + "amount=" + amount
            
            let clientTokenURL = NSURL(string: "http://thepk.xyz:8080/PayRap/api/payment/checkout")!
            let clientTokenRequest = NSMutableURLRequest(url: clientTokenURL as URL)
            clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
            clientTokenRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
            clientTokenRequest.httpMethod = "POST"
            clientTokenRequest.httpBody = bodyData.data(using: .utf8)!
            
            URLSession.shared.dataTask(with: clientTokenRequest as URLRequest) { (data, response, error) -> Void in
        
                    let response = String(data: data!, encoding: String.Encoding.utf8)
                    if response! == "1"{
                        // After receiving the success signal from server, adding the transaction to Firebase
                        self.addAmountToFirebase(amount: amount)
                    }

                }.resume()
        }
    }
    

    // Add self transaction information to Firebase database
    func addAmountToFirebase(amount: String){
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        let refUser = ref.child("users").child(userID!)
        let refTransaction = ref.child("transaction")
        
        let defaults = UserDefaults.standard
        let senderEmail = defaults.string(forKey: "email")
        let fullname = defaults.string(forKey: "fullname")
        
        let interval = NSDate().timeIntervalSince1970
        
        // Adding the amount to the user balance
        refUser.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var data = currentData.value as? [String: Any]  {
                
                var balance = data["balance"] as! Float
                let amountInFloat = (amount as NSString).floatValue
                balance = balance + amountInFloat
                data["balance"] = balance
                currentData.value = data
                
                // Adding a record under user's transaction list
                refTransaction.child(userID!).childByAutoId().setValue(["type":0, "amount":amountInFloat, "note":"Self Transfer", "sender":senderEmail! , "senderName": fullname!, "date":interval, "receiver":"", "receiverName":""])
                
                  return FIRTransactionResult.success(withValue: currentData)
                }
             return FIRTransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let resultViewController = storyBoard.instantiateViewController(withIdentifier: "dashboardController")
                self.navigationController?.pushViewController(resultViewController, animated: true)
            }
        }

        
    }
    
}
