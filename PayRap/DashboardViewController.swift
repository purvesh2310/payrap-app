//
//  DashboardViewController.swift
//  PayRap
//
//  Created by Purvesh Kothari on 5/10/17.
//  Copyright © 2017 Purvesh Kothari. All rights reserved.
//

import UIKit
import Firebase

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: FIRDatabaseReference!
    var transactions = [Transaction]()
    var orderedTransaction = [Transaction]()
    var tableUtility: PayRapTableUtility?

    @IBOutlet weak var transactionTableView: UITableView!
    @IBOutlet weak var balanceLabel: UILabel!

    override func viewDidLoad() {

        ref = FIRDatabase.database().reference()
        tableUtility = PayRapTableUtility()
        
        getCurrentBalance()
        getUsersTransaction()
        
        transactionTableView.delegate = self
        transactionTableView.dataSource = self

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionItem", for: indexPath) as! TransactionTableViewCell

        // Creating a table cell for display in transaction list
        let amount: Float = orderedTransaction[indexPath.row].amount
        let type: Int = orderedTransaction[indexPath.row].type
        let receiver: String = orderedTransaction[indexPath.row].receiverName
        let sender: String = orderedTransaction[indexPath.row].senderName
        let transactionNote: String = orderedTransaction[indexPath.row].note
        let createDate: NSDate = orderedTransaction[indexPath.row].createDate
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy HH:mm"
        let dateString = dateFormatter.string(from: createDate as Date)
       
        var amountString: String
        var transactionHeader: String
        
        if type == 0 {
            transactionHeader = "You added money to account"
            amountString = "+ " + "$" + amount.description
        } else if type == 2 {
            transactionHeader = sender + " paid you"
            amountString = "+ " + "$" + amount.description
        } else{
            transactionHeader = "You paid " + receiver
            amountString = "- " + "$" + amount.description
        }
        
        cell.amountLabel.text = amountString
        cell.dateLabel.text = dateString
        cell.transactionHeadingLabel.text = transactionHeader
        cell.transactionNoteLabel.text = transactionNote
        
        return cell;
    }
    
    // Getting current balance of User
    func getCurrentBalance(){
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        ref.child("users").child(userID!).observe(FIRDataEventType.value, with: { (snapshot) in
        
            let userDict = snapshot.value as? [String : AnyObject] ?? [:]
            let currentBalance = userDict["balance"] as? Float ?? 0.0
        
            self.balanceLabel.text = "$" + String(currentBalance)
        
        }) { (error) in
            let utility = PayRapAlertUtility()
            utility.displayAlertWithMessage(viewController: self, errorMsg: error.localizedDescription)
        }
    }
    
    // Getting all transactions from the Firebase
    func getUsersTransaction(){
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        ref.child("transaction").child(userID!).observe(.childAdded, with: { (snapshot) -> Void in
          
            if let snapDict = snapshot.value as? [String:AnyObject]{
    
                let sender = snapDict["sender"] as! String
                let receiver = snapDict["receiver"] as! String
                let senderName = snapDict["senderName"] as! String
                let receiverName = snapDict["receiverName"] as! String
                let note = snapDict["note"] as! String
                let amount = snapDict["amount"] as! NSNumber
                let amountInFloat = amount.floatValue
               
                let dateInNumber = snapDict["date"] as! NSNumber
                let dateInDouble: Double = dateInNumber as! Double
                let date = NSDate(timeIntervalSince1970: dateInDouble)
                
                let type = snapDict["type"] as! NSNumber
                let intType = type.intValue
                
                let transaction = Transaction(senderEmail: sender, receiverEmail: receiver, senderName: senderName, receiverName: receiverName, amount: amountInFloat, createDate: date, type: intType, note: note)
                
                self.transactions.append(transaction)
                
                DispatchQueue.main.async {
                    self.orderedTransaction = self.transactions.reversed()
                    self.transactionTableView.reloadData()
                }
            }
            
        })
    }
}
