//
//  InitialViewController.swift
//  FinalKnife
//
//  Created by Trivedi on 12/2/18.
//  Copyright © 2018 Trivedi. All rights reserved.
//

import UIKit
import Firebase

class InitialViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Checking if user exist or not
        if Auth.auth().currentUser != nil{
            performSegue(withIdentifier: "toMainScreenFromHome", sender: self)
        }
        hideKeyboardWhenTappedAround()
    }

    @IBAction func signIn(_ sender: Any) {
        if let password = passwordTextField.text , let email = emailTextField.text{
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if error != nil{
                    self.showError(errorMessege: (error?.localizedDescription)!)
                }else{
                    self.performSegue(withIdentifier: "toMainScreenFromHome", sender: sender)
                }
                guard (user?.user) != nil else { return }
            }
        }else{
            showError(errorMessege: "Please add email & password")
        }
    }
    func showError(errorMessege:String) {
        let alert = UIAlertController(title: "Error", message: errorMessege, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func backToInitial(unwindSegue:UIStoryboardSegue){
    }
    

}
//Hide keyboard when touch outside textview
extension InitialViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(InitialViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
