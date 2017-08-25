//
//  SendMoneyViewController.swift
//  PayRap
//
//  Created by Purvesh Kothari on 5/11/17.
//  Copyright © 2017 Purvesh Kothari. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import QRCodeReader

class SendMoneyViewController: UIViewController, UITextViewDelegate, QRCodeReaderViewControllerDelegate{
    
    @IBOutlet weak var sendAmountTextField: UITextField!
    @IBOutlet weak var reciverEmailAddressTextField: UITextField!
    @IBOutlet weak var paymentDescriptionTextView: UITextView!
    @IBOutlet weak var previewView: UIView!
    
    var placeholderLabel : UILabel!
    var ref: FIRDatabaseReference!
    var receiverFullName: String!
    var receiverUniqueKey: String!
    var isReceiverValid: Bool!
    var isAmountValid: Bool!
    var isTransactionNoteProvided: Bool!
    var alertUtility: PayRapAlertUtility!
    
    lazy var reader: QRCodeReader = QRCodeReader()
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
            $0.showTorchButton = true
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    override func viewDidLoad() {
        
        ref = FIRDatabase.database().reference()
        alertUtility = PayRapAlertUtility()
        
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(sendMoney(sender:)))
        navigationItem.rightBarButtonItem = button
        
        paymentDescriptionTextView.delegate = self
        setPlaceHolderForTextView()
        
        paymentDescriptionTextView.layer.borderWidth = 1
        paymentDescriptionTextView.layer.borderColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.0).cgColor
        paymentDescriptionTextView.layer.cornerRadius = 5
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    
        view.addGestureRecognizer(tap)
        
    }
    
    // Starts scanning QR code
    @IBAction func scan(_ sender: Any) {
        
        readerVC.delegate = self
        
        // Or by using the closure pattern
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            
        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
        
    }
    
    // Sending money to the receiver
    func sendMoney(sender: UIBarButtonItem){
        
        let enteredAmount: String? = sendAmountTextField.text
        let amountInFloat: Float = (enteredAmount! as NSString).floatValue
        
        let defaults = UserDefaults.standard
        let senderEmailAddress = defaults.string(forKey: "email")
        let fullname: String = defaults.string(forKey: "fullname")!
        let senderUniqueKey = FIRAuth.auth()?.currentUser?.uid
        
        let receiverEmailAddress: String? = reciverEmailAddressTextField.text
        let transactionNote: String? = paymentDescriptionTextView.text
        
        if transactionNote?.characters.count == 0 {
            alertUtility.displayAlertWithMessage(viewController: self, errorMsg: "Please enter transaction note to proceed.")
            
            isTransactionNoteProvided = false
        } else {
            isTransactionNoteProvided = true
        }
        
        let interval = NSDate().timeIntervalSince1970
        
        if isAmountValid == true && isReceiverValid == true && isTransactionNoteProvided == true {
            
            let refUser = ref.child("users")
            
            // Running a transaction block on users
            refUser.runTransactionBlock { (currentData: FIRMutableData) -> FIRTransactionResult in
                if var data = currentData.value as? [String: Any] {
                   
                    // Deducting the balance from sender
                    if var senderData = data[senderUniqueKey!] as? [String: Any]{
                        var balance = senderData["balance"] as! Float
                        balance = balance - amountInFloat
                        senderData["balance"] = balance
                        data[senderUniqueKey!] = senderData
                    }
                    
                    // Adding balance to receiver
                    if var receiverData = data[self.receiverUniqueKey] as? [String: Any]{
                        var balance = receiverData["balance"] as! Float
                        balance = balance + amountInFloat
                        receiverData["balance"] = balance
                        data[self.receiverUniqueKey] = receiverData
                    }
                    
                    currentData.value = data
                   
                    return FIRTransactionResult.success(withValue: currentData)
                }
                return FIRTransactionResult.success(withValue: currentData)
            }
            
            // Adding a transaction record for the sender
            ref.child("transaction").child(senderUniqueKey!).childByAutoId().setValue(["type":1, "amount":amountInFloat, "note":transactionNote!, "sender":senderEmailAddress!, "receiver":receiverEmailAddress!, "date": interval, "senderName": fullname, "receiverName": receiverFullName])
            
            // Adding a transaction record for the receiver
            ref.child("transaction").child(receiverUniqueKey).childByAutoId().setValue(["type":2, "amount":amountInFloat, "note":transactionNote!, "sender":senderEmailAddress!, "receiver":receiverEmailAddress!, "date": interval, "senderName": fullname, "receiverName": receiverFullName])
            
            // Navigating to Dashboard after successful completion
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let resultViewController = storyBoard.instantiateViewController(withIdentifier: "dashboardController")
            self.navigationController?.pushViewController(resultViewController, animated: true)
        }
    }
    
    // Manually setting the placeholder for the text view
    func setPlaceHolderForTextView(){
        
        placeholderLabel = UILabel()
        placeholderLabel.text = "Payment Note"
        placeholderLabel.font = UIFont.systemFont(ofSize: (paymentDescriptionTextView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        paymentDescriptionTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (paymentDescriptionTextView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !paymentDescriptionTextView.text.isEmpty
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Called when amount field completes editing
    @IBAction func checkForAvailableBalance(_ sender: Any) {
        let enteredAmount: String? = sendAmountTextField.text
        let amountInFloat: Float = (enteredAmount! as NSString).floatValue
        
        validateTransferAmount(amount: amountInFloat)
    }
    
    // Called when receiver text field completes editing
    @IBAction func checkForReceiverAccount(_ sender: Any) {
        let receiverEmailAddress: String? = reciverEmailAddressTextField.text
        
        validateReceiver(emailAddress: receiverEmailAddress)
    }
    
    // Validates that user has balance to transfer the amount
    func validateTransferAmount(amount: Float){

        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get user value
            let value = snapshot.value as? NSDictionary
            let currentBalance = value?["balance"] as? Float ?? 0.0
            
            if amount > currentBalance{
                self.alertUtility.displayAlertWithMessage(viewController: self, errorMsg: "Insufficient Balance. Please add money to your account.")
            } else{
                self.isAmountValid = true
            }
            
        }) { (error) in
            self.alertUtility.displayAlertWithMessage(viewController: self, errorMsg: error.localizedDescription)
        }
        
    }
    
    // Validates that the user exists with given email address
    func validateReceiver(emailAddress: String?){
        
        let utility = PayRapAlertUtility()
        
        ref.child("users").queryOrdered(byChild: "email").queryEqual(toValue: emailAddress).observeSingleEvent(of: .value, with: { (snapShot) in
            
            if let snapDict = snapShot.value as? [String:AnyObject]{
                
                self.isReceiverValid = true
                
                for each in snapDict{
                
                    let firstname = each.value["firstname"] as! String
                    let lastname = each.value["lastname"] as! String
                    self.receiverFullName = firstname + " " + lastname
                
                    let key = each.key
                    self.receiverUniqueKey = key
                 }
            } else{
    
                utility.displayAlertWithMessage(viewController: self, errorMsg: "No user found with given email address.")
            }
        }, withCancel: {(error) in
            utility.displayAlertWithMessage(viewController: self, errorMsg: error.localizedDescription)
        })
    }
    
    // QRCode Scan Delegate Method
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        dismiss(animated: true) { [weak self] in
            let receiverEmail = result.value
            self?.reciverEmailAddressTextField.text = receiverEmail
            self?.validateReceiver(emailAddress: receiverEmail)
        }
    }
    
    // QRCode Scan Delegate Method
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        if let cameraName = newCaptureDevice.device.localizedName {
            print("Switching capturing to: \(cameraName)")
        }
    }
    
    // QRCode Scan Delegate Method
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
    
    // Checking the permission regarding the Camera access
    private func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
        } catch let error as NSError {
            let alert: UIAlertController?
            
            switch error.code {
            case -11852:
                alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)
                
                alert?.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
                    DispatchQueue.main.async {
                        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                            UIApplication.shared.openURL(settingsURL)
                        }
                    }
                }))
                
                alert?.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            case -11814:
                alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
                alert?.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            default:
                alert = nil
            }
            
            guard let vc = alert else { return false }
            
            present(vc, animated: true, completion: nil)
            
            return false
        }
    }
    
}
