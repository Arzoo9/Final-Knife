//
//  SignInViewController.swift
//  FinalKnife
//
//  Created by Trivedi on 12/1/18.
//  Copyright © 2018 Trivedi. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {

   
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func signIn(_ sender: Any) {
        //Checking for fields
        if let password = passwordTextField.text , let email = emailTextField.text{
            //Authentication user using firebase Authentication
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if error != nil{
                    self.showError(errorMessege: (error?.localizedDescription)!)
                }else{
                    self.performSegue(withIdentifier: "toHomeFromSingIn", sender: sender)
                }
                guard let user = user?.user else { return }
                print(user)
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
