//
//  SignUpViewController.swift
//  PayRap
//
//  Created by Purvesh Kothari on 4/29/17.
//  Copyright © 2017 Purvesh Kothari. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController{
    
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signUpScrollView: UIScrollView!
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        
        signUpButton.layer.cornerRadius = 10
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
        ref = FIRDatabase.database().reference()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func performSignUp(_ sender: Any) {
        
        let email: String! = emailAddressTextField.text
        let password: String! = passwordTextField.text
        let confirmPassword: String! = confirmPasswordTextField.text
        
        let firstname: String! = firstnameTextField.text
        let lastname: String! = lastnameTextField.text
        let fullname = firstname + " " + lastname
        
        let utility = PayRapAlertUtility()
        
        if password != confirmPassword {
            utility.displayAlertWithMessage(viewController: self, errorMsg: "Passwords do not match.")
        }
        
        // Creating a user in Firebase
        FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
            
            if error == nil {
                
                // Adding User's personal information in User document in Firebase
                self.ref.child("users").child(user!.uid).setValue(["firstname": firstname,"lastname":lastname,"email":email,"balance":0.0])
                
                let defaults = UserDefaults.standard
                defaults.set(email, forKey: "email")
                defaults.set(fullname, forKey: "fullname")
                
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "dashboardNavigationController")
                
                self.present(viewController!, animated: true, completion: nil)
            } else {
                utility.displayAlertWithMessage(viewController: self, errorMsg: error?.localizedDescription)
            }
        }
    }
    
    // Adjust scrolling when keyboard appears on the screen for editing
    func keyboardWillShow(_ notification: NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset:UIEdgeInsets = self.signUpScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.signUpScrollView.contentInset = contentInset
    }
    
    // Re-adjust scrolling when keyboard hides from the screen
    func keyboardWillHide(_ notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.signUpScrollView.contentInset = contentInset
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
        
        self.navigationController?.isNavigationBarHidden = false
        
    }
}
