//
//  AddRecipeViewController.swift
//  FinalKnife
//
//  Created by Trivedi on 12/2/18.
//  Copyright © 2018 Trivedi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class AddRecipeViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{
    @IBOutlet weak var recipeTableView: UITableView!
    @IBOutlet var addItemView: UIView!
    @IBOutlet weak var recipePhotoUIImageView: UIImageView!
    var selecteImageFromPicker : UIImage?
    var photoURL:String? = nil
    var recipeName : String = ""
    var ingredients : NSDictionary = [:]
    var selectedRecipe : [Item] = []
    var recipe : [Item] = []
    var autoRecipeIdReference: DatabaseReference = DatabaseReference()

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        getIngredientsData()
        //Check if created new one or edited exsting one
        if selectedRecipe.isEmpty{
            createAutorecipeIdReference()
        }else{
            getSelectedRecipeImage()
        }
    }
    func setNavigationBar(){
        self.navigationItem.title = recipeName
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
    }
    func getIngredientsData(){
        let ref: DatabaseReference! = Database.database().reference()
        ref.child("ingredients").observeSingleEvent(of: .value, with: {
            (snapshot) in
            self.ingredients = (snapshot.value as? NSDictionary)!
            self.loadRecipe()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    func loadRecipe(){
        recipe = selectedRecipe
        recipeTableView.reloadData()
    }
    func createAutorecipeIdReference(){
        let ref: DatabaseReference! = Database.database().reference()
        autoRecipeIdReference = ref.child("users").child((Auth.auth().currentUser?.uid)!).child("recipes").childByAutoId()
    }
    func getSelectedRecipeImage(){
        if let photoURL = photoURL{
            let gsReference = Storage.storage().reference(forURL: photoURL)
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            gsReference.getData(maxSize: 5 * 1024 * 1024) { data, error in
                if error != nil{
                    print(error!)
                } else {
                    print(self.photoURL!)
                    DispatchQueue.main.async {
                        self.recipePhotoUIImageView.image = UIImage(data: data!)
                    }
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipe.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if let recipeId = recipe[indexPath.row].id{
            let ingredientId = recipe[indexPath.row].id!
            //spliting id by half to get it's type
            let bound = ingredientId.index(ingredientId.startIndex, offsetBy:1)
            let ingredientTypeId = ingredientId[ingredientId.startIndex...bound]
            let ingredientsDictonary = ingredients[ingredientTypeId] as! NSDictionary
             cell.textLabel?.text = "\(ingredientsDictonary[recipeId]!) - \(recipe[indexPath.row].text)"
        }else{
             cell.textLabel?.text = "\(recipe[indexPath.row].text)"
        }
        return cell
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedItem = recipe[sourceIndexPath.item]
        recipe.remove(at: sourceIndexPath.item)
        recipe.insert(movedItem, at: destinationIndexPath.item)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            recipe.remove(at: indexPath.item)
            recipeTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //creating alert for adding quantity
        let alert = UIAlertController(title: "", message: "Edit Text", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
            if let text = alert.textFields?.first?.text, text != ""{
                self.recipe[indexPath.row].setText(text: text)
                self.recipeTableView.reloadData()
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
    
    @IBAction func addText(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "Add Text", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
            if let text = alert.textFields?.first?.text, text != ""{
                if text.contains(";"){
                    self.showError(errorMessege: "Semicolon (;) is not allowed charcter")
                }else{
                     self.recipe.append(Item(text: text))
                }
            }
            self.recipeTableView.reloadData()
        }))
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Your Recipe Name"
            textField.textAlignment = .center
        })
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func addItem(_ sender: Any) {
    }
    @IBAction func addPhoto(_ sender: Any) {
       handleAddPhotoImageView()
    }
    @IBAction func save(_ sender: Any) {
        if recipe.isEmpty{
            showError(errorMessege: "Please add at least one item")
        }else{
            let storageReferance = Storage.storage().reference().child("\(autoRecipeIdReference).jpeg")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            //Check if user have selected iamge
            if let selectedImage = selecteImageFromPicker{
                //Compress and convert to JPEG
                if let data = selectedImage.jpegData(compressionQuality: CGFloat(0.25)){
                    storageReferance.putData(data, metadata: metadata) { (metadata, error) in
                        //Error Checking
                        if error != nil{
                            self.showError(errorMessege: "Something went wrong while uploading image please try again")
                            return
                        }
                        storageReferance.downloadURL { (url, error) in
                            //Error Checking
                            if error != nil{
                                self.showError(errorMessege: "Something went wrong while uploading image please try again")
                                return
                            }
                            if let downloadURL = url {
                                self.autoRecipeIdReference.setValue(["name": self.recipeName,"photoURL":downloadURL.absoluteString])
                                var i = 0
                                //adding all the items in the recipe
                                for item in self.recipe{
                                    if let id = item.id{
                                        //for predefine items
                                        self.autoRecipeIdReference.child("recipe").child("\(i)").setValue("\(id);\(item.text)")
                                    }else{
                                        //for text notes
                                        self.autoRecipeIdReference.child("recipe").child("\(i)").setValue(item.text)
                                    }
                                    i = i+1
                                }
                                self.showMessege(messege: "Saved Successfully")
                            }else{
                                self.showError(errorMessege: "Error occured while uploading image")
                            }
                        }
                    }
                }
                //Check if user editing recipe and it alaready have photo no keep the same URL
            }else if recipePhotoUIImageView.image != nil, photoURL != nil{
                self.autoRecipeIdReference.setValue(["name": self.recipeName,"photoURL":photoURL])
                var i = 0
                //adding all the items in the recipe
                for item in self.recipe{
                    if let id = item.id{
                        self.autoRecipeIdReference.child("recipe").child("\(i)").setValue("\(id);\(item.text)")
                    }else{
                        self.autoRecipeIdReference.child("recipe").child("\(i)").setValue(item.text)
                    }
                    i = i+1
                }
                    self.showMessege(messege: "Saved Successfully")
                //Save recipe without photo
            }else{
                 autoRecipeIdReference.setValue(["name": recipeName])
                var i = 0
                //adding all the items in the recipe
                for item in recipe{
                    if let id = item.id{
                        autoRecipeIdReference.child("recipe").child("\(i)").setValue("\(id);\(item.text)")
                    }else{
                        autoRecipeIdReference.child("recipe").child("\(i)").setValue(item.text)
                    }
                    i = i+1
                }
                 self.showMessege(messege: "Saved Successfully")
            }
        }
    }
    @IBAction func edit(_ sender: Any) {
        self.recipeTableView.isEditing = !self.recipeTableView.isEditing
        (sender as! UIBarButtonItem).title = self.recipeTableView.isEditing ? "Done" : "Edit"
    }
    @IBAction func closeAddItemView(_ sender: Any) {
           self.addItemView.removeFromSuperview()
    }
    @IBAction func backAddRecipe(unwindSegue:UIStoryboardSegue){
        recipeTableView.reloadData()
    }
    func showError(errorMessege:String) {
        let alert = UIAlertController(title: "Error", message: errorMessege, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func showMessege(messege:String) {
        let alert = UIAlertController(title: "", message: messege, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }

}
