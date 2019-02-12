//
//  IngredientsViewController.swift
//  FinalKnife
//
//  Created by Trivedi on 12/4/18.
//  Copyright © 2018 Trivedi. All rights reserved.
//

import UIKit
import Firebase

class IngredientsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{
    var ingredientId : String = "01"
    var IngredientsDataSource : NSDictionary = [:]

    @IBOutlet weak var IngredientsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
       getIngredients()
    }
    func getIngredients(){
        let ref: DatabaseReference! = Database.database().reference()
        //getting data from firebase
        ref.child("ingredients").child(ingredientId).observeSingleEvent(of: .value, with: {
            (snapshot) in
            self.IngredientsDataSource = (snapshot.value as? NSDictionary)!
            self.IngredientsTableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return IngredientsDataSource.allKeys.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var sortedKeys = (IngredientsDataSource.allKeys as! [String]).sorted(by: <)
        let ingredientId = sortedKeys[indexPath.row]
        let ingredientData = IngredientsDataSource[ingredientId] as! String
        cell.textLabel?.text = ingredientData
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var sortedKeys = (IngredientsDataSource.allKeys as! [String]).sorted(by: <)
        let item : Item = Item(id: sortedKeys[indexPath.row],text: "")
        //creating alert for adding quantity
        let alert = UIAlertController(title: "Add Item", message: "Add Quantity", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
            if let recipieName = alert.textFields?.first?.text{
                item.setText(text: recipieName)
            }
            self.performSegue(withIdentifier: "backToAddRecipeUnwindSegue", sender: item)
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addRecipeViewController = segue.destination as? AddRecipeViewController{
            addRecipeViewController.recipe.append(sender as! Item)
        }
    }

}
