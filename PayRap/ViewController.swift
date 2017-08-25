//
//  ViewController.swift
//  PayRap
//
//  Created by Purvesh Kothari on 4/4/17.
//  Copyright © 2017 Purvesh Kothari. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    
    @IBOutlet weak var signInScrollView: UIScrollView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.layer.cornerRadius = 10
        signUpButton.layer.cornerRadius = 10
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }

    @IBAction func performSignIn(_ sender: Any) {
        
        let emailAddress: String! = usernameTextField.text
        let password: String! = passwordTextField.text
        
        let utility = PayRapAlertUtility()
        
        FIRAuth.auth()?.signIn(withEmail: emailAddress, password: password) { (user, error) in
            if error == nil {
                let defaults = UserDefaults.standard
                defaults.set(emailAddress, forKey: "email")
                self.performSegue(withIdentifier: "goToDashboard", sender: self)
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
        var contentInset:UIEdgeInsets = self.signInScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.signInScrollView.contentInset = contentInset
    }
    
    // Re-adjust scrolling when keyboard hides from the screen
    func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.signInScrollView.contentInset = contentInset
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
        
        self.navigationController?.isNavigationBarHidden = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func unwindToSignInScreen(sender: UIStoryboardSegue) {
        
    }
}

