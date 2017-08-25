//
//  ManageCardViewController.swift
//  PayRap
//
//  Created by Purvesh Kothari on 4/27/17.
//  Copyright © 2017 Purvesh Kothari. All rights reserved.
//

import UIKit
import RealmSwift

class ManageCardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var cardInformationTableView: UITableView!
    var cards: Results<CreditCard>? = nil
    var tableUtility: PayRapTableUtility?
    
    override func viewDidLoad() {
        
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(goToAddCardView(sender:)))
        navigationItem.rightBarButtonItem = button
        
        let realm = try! Realm()
        cards = realm.objects(CreditCard.self)
        
        tableUtility = PayRapTableUtility()
        
        cardInformationTableView.delegate = self
        cardInformationTableView.dataSource = self
        cardInformationTableView.tableFooterView = UIView()
        
    }
    
    func goToAddCardView(sender: UIBarButtonItem){
        performSegue(withIdentifier: "goToAddCardView", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cardItem", for: indexPath)
        
        if let cardNumber = cards?[indexPath.row].creditCardNumber {
            
            let lastFourDigits = cardNumber.substring(from:cardNumber.index(cardNumber.endIndex, offsetBy: -4))
            
            cell.textLabel?.text = "Card ending in " + lastFourDigits
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        let noOfCardStored: Int = (cards?.count)!
        
        if(noOfCardStored > 0){
            cardInformationTableView.backgroundView = nil
            return 1
        }else {
            tableUtility?.displayTableEmptyMessage(tableView: cardInformationTableView, message: "You don't have any card saved yet.\nPlease save card information to get started.")
           // EmptyMessage(message: )
            return 0
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let noOfCardStored: Int = (cards?.count)!
        return noOfCardStored;
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        cardInformationTableView.reloadData()
    }
}
