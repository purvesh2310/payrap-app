//
//  MenuViewController.swift
//  PayRap
//
//  Created by Purvesh Kothari on 4/26/17.
//  Copyright © 2017 Purvesh Kothari. All rights reserved.
//
import SideMenu
import UIKit
import Firebase
import RealmSwift

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var menuItemTableView: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var items: [String] = ["Dashboard","Add Money", "Send Money","Manage Cards","QR Code","Terms of Use"]
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting white border below the profile view to separate from TableView
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(0.0, profileView.frame.height-1, profileView.frame.width, 0.4)
        bottomBorder.backgroundColor = UIColor.white.cgColor
        profileView.layer.addSublayer(bottomBorder)
        
        menuItemTableView.delegate = self
        menuItemTableView.dataSource = self
        
        SideMenuManager.menuFadeStatusBar = false
        setUsername()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Hiding the default navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = self.menuItemTableView.dequeueReusableCell(withIdentifier: "menuItem")!
        cell.textLabel?.text = self.items[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        
        return cell
    
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let itemSelected: Int = indexPath.row
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        // Navigating to appropriate Viewontroller based on the option selected
        switch itemSelected {
            case 0:

                let resultViewController = storyBoard.instantiateViewController(withIdentifier: "dashboardController")
                self.navigationController?.pushViewController(resultViewController, animated: true)
                break
            
            case 1:
            
                let resultViewController = storyBoard.instantiateViewController(withIdentifier: "addMoneyController")
                self.navigationController?.pushViewController(resultViewController, animated: true)
                break
            
            case 2:
            
                let resultViewController = storyBoard.instantiateViewController(withIdentifier: "sendMoneyController")
                self.navigationController?.pushViewController(resultViewController, animated: true)
                break
            
            case 3:
            
                let resultViewController = storyBoard.instantiateViewController(withIdentifier: "manageCardController") as! ManageCardViewController
                self.navigationController?.pushViewController(resultViewController, animated: true)
                break
            
            case 4:
            
                let resultViewController = storyBoard.instantiateViewController(withIdentifier: "qrCodeDisplayController")
                self.navigationController?.pushViewController(resultViewController, animated: true)
                break
            case 5:
                let resultViewController = storyBoard.instantiateViewController(withIdentifier: "termsPolicyViewControlller")
                self.navigationController?.pushViewController(resultViewController, animated: true)
            break
            default:
                print("Choose valid Option")
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100.0;
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView(frame:
            CGRect(0,0,menuItemTableView.frame.size.width,menuItemTableView.frame.size.height))
        
        // Setting signout button under the table view
        let signoutButton = UIButton(type: .custom)
        signoutButton.layer.cornerRadius = 10
        signoutButton.layer.cornerRadius = 10
        signoutButton.setTitle("Sign Out", for: UIControlState.normal)
        signoutButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        signoutButton.backgroundColor = UIColor(red:0.09, green:0.77, blue:0.98, alpha:1.0)
        signoutButton.addTarget(self, action: #selector(signOutUser(button:)), for: .touchUpInside)
        
        signoutButton.frame = CGRect(40, 80, 200, 40)
        
        footerView.addSubview(signoutButton)
        
        return footerView
        
    }
    
    // Performs signing out of the user
    func signOutUser(button: UIButton) {
        
        let realm = try! Realm()
       
        try! realm.write {
            let result = realm.objects(CreditCard.self)
            realm.delete(result)
        }
        
        let firebaseAuth = FIRAuth.auth()
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        do {
            try firebaseAuth?.signOut()
            
            let viewController = storyBoard.instantiateViewController(withIdentifier: "signInViewController")
            
            self.navigationController?.pushViewController(viewController, animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Unhiding the default navigation bar so that it is visible in other controllers
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // Display username in the Side navigation menu
    func setUsername(){
        
        let defaults = UserDefaults.standard
        
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        // Get user value from Firebase
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            
            let value = snapshot.value as? NSDictionary
            
            let firstname = value?["firstname"] as? String ?? ""
            let lastname = value?["lastname"] as? String ?? ""
            let fullname = firstname + " " + lastname
            
            self.usernameLabel.text = fullname
            
            defaults.set(fullname, forKey: "fullname")
            
        }) { (error) in
            let utility = PayRapAlertUtility()
            utility.displayAlertWithMessage(viewController: self, errorMsg: error.localizedDescription)
        }
        
    }

}
