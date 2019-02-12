//
//  HomeViewController.swift
//  FinalKnife
//
//  Created by Trivedi on 12/1/18.
//  Copyright © 2018 Trivedi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var yourRecipeTableView: UITableView!
    var yourRecipeDataSource : NSDictionary = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        getYourRecipe()
    }
    
    func setNavigationBar(){
        let user = Auth.auth().currentUser
        //Getting login in user name
        if let userName = user?.displayName{
            self.navigationItem.title = "Hey, \(userName)!"
        }else{
            self.navigationItem.title = "Your Recipes!"
        }
    }
    func getYourRecipe(){
        //Fetching recipes from database
        let ref: DatabaseReference! = Database.database().reference()
        let user = Auth.auth().currentUser
        ref.child("users").child((user?.uid)!).child("recipes").observe(DataEventType.value, with: { (snapshot) in
            if snapshot.exists(){
                self.yourRecipeDataSource = snapshot.value as! NSDictionary
                self.yourRecipeTableView.reloadData()
            }else{
                self.yourRecipeDataSource = [:]
                self.yourRecipeTableView.reloadData()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return yourRecipeDataSource.allKeys.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = yourRecipeTableView.dequeueReusableCell(withIdentifier: "yourRecipeCell")
        let recipieID = yourRecipeDataSource.allKeys[indexPath.row] as! String
        let yourRecipeData = yourRecipeDataSource[recipieID] as! NSDictionary
        //Giving defualt image
        cell?.imageView?.image = UIImage(named: "empty-photo")
        //Check if the recipe has image replace it with default image
        if let imageURL = yourRecipeData["photoURL"] as? String{
            let storage = Storage.storage()
            let gsReference = storage.reference(forURL: imageURL)
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            
            //Formating cell image
            cell?.imageView?.translatesAutoresizingMaskIntoConstraints = false
            cell?.imageView?.layer.cornerRadius = 35
            cell?.imageView?.layer.masksToBounds = true
            cell?.imageView?.contentMode = .scaleAspectFill
 
            gsReference.getData(maxSize: 5 * 1024 * 1024) { data, error in
                //Error checking
                if error != nil{
                    print(error!)
                } else {
                    //Async tast to perform when photos are loaded
                    DispatchQueue.main.async {
                       
                        
                        cell?.imageView?.image = UIImage(data: data!)
                    }  
                }
            }//.resume()
        }
        cell!.textLabel?.text = yourRecipeData["name"] as? String
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipieID = yourRecipeDataSource.allKeys[indexPath.row] as! String
        performSegue(withIdentifier: "toAddRecipie", sender: recipieID)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            let recipieID = yourRecipeDataSource.allKeys[indexPath.row] as! String
            let ref: DatabaseReference! = Database.database().reference()
            let user = Auth.auth().currentUser
        ref.child("users").child((user?.uid)!).child("recipes").child(recipieID).removeValue()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    @IBAction func logout(_ sender: Any) {
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "backToInitial", sender: self)
    }
    
    @IBAction func addRecipie(_ sender: Any) {
        let alert = UIAlertController(title: "Add New Recipe", message: "Give name to your recipe", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
              if let text = alert.textFields?.first?.text, text != ""{
                self.performSegue(withIdentifier: "toAddRecipie", sender: alert.textFields?.first)
              }else{
                self.showError(errorMessege: "Please add name")
            }
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .cancel, handler: { _ in
            NSLog("The \"cancel\" alert occured.")
        }))
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Your Recipe Name"
            textField.textAlignment = .center
        })
        self.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func edit(_ sender: Any) {
        self.yourRecipeTableView.isEditing = !self.yourRecipeTableView.isEditing
        (sender as! UIBarButtonItem).title = self.yourRecipeTableView.isEditing ? "Done" : "Edit"
    }
    func showError(errorMessege:String) {
        let alert = UIAlertController(title: "Error", message: errorMessege, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toAddRecipie") {
            if let target = segue.destination as? AddRecipeViewController {
                if let recipeNameTextField = sender as? UITextField{
                     target.recipeName = recipeNameTextField.text!
                }
                else if let recipieID = sender as? String{
                   let recipeData = yourRecipeDataSource[recipieID] as! NSDictionary
                    target.recipeName = recipeData["name"] as! String
                    if let items = recipeData["recipe"] as? NSArray{
                        var recipe : [Item] = []
                        for item in items{
                            if (item as! String).contains(";"){
                                 let itemData = (item as! String).split(separator: ";")
                                if itemData.indices.contains(1){
                                     recipe.append(Item(id: String(itemData[0]), text: String(itemData[1])))
                                }else{
                                     recipe.append(Item(id: String(itemData[0]), text: ""))
                                }
                                
                            }else{
                                recipe.append(Item(text: item as! String))
                            }
                        }
                        let user = Auth.auth().currentUser
                        let ref = Database.database().reference().child("users").child((user?.uid)!).child("recipes").child(recipieID)
                        target.autoRecipeIdReference = ref
                        target.selectedRecipe = recipe
                        if let photoURL = recipeData["photoURL"] as? String{
                            target.photoURL = photoURL
                        }
                    }
                }
            }
        }
    }
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
}
