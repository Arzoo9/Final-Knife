//
//  ViewController.swift
//  FinalKnife
//
//  Created by Trivedi on 11/30/18.
//  Copyright © 2018 Trivedi. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
    
    @IBAction func singUp(_ sender: Any) {
        // Checking for empty feilds
        if  let name = nameTextField.text, let password = passwordTextField.text , let email = emailTextField.text{
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                if error != nil{
                    self.showError(errorMessege: (error?.localizedDescription)!)
                }else{
                    //Authenticating user using firebase Authentication
                    let changeRequset = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequset?.displayName = name
                        changeRequset?.commitChanges{ error in
                            if error != nil{
                                self.showError(errorMessege: (error?.localizedDescription)!)
                            }else{
                                let alert = UIAlertController(title: "", message: "Successly fully registered", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                                    let ref: DatabaseReference! = Database.database().reference()
                                    ref.child("users").child((Auth.auth().currentUser?.uid)!).setValue(["username": name])
                                    self.performSegue(withIdentifier: "toHomeFromSingUp", sender: self)
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                    }
                }
            }
        }
    }
    func showError(errorMessege:String) {
        let alert = UIAlertController(title: "Error", message: errorMessege, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }

}
//Hide keyboard when touch outside textview
extension ViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
