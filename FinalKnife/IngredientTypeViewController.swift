//
//  IngredientTypeViewController.swift
//  FinalKnife
//
//  Created by Trivedi on 12/4/18.
//  Copyright © 2018 Trivedi. All rights reserved.
//

import UIKit
import Firebase

class IngredientTypeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    var ref: DatabaseReference! = Database.database().reference().child("ingredients_types")
    @IBOutlet weak var IngredientTypeTableView: UITableView!
    var IngredientTypeDataSource : NSDictionary = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        getIngredientsTypes()
    }
    func getIngredientsTypes(){
        ref.queryOrderedByValue().observeSingleEvent(of: .value, with: {
            (snapshot) in
            print(snapshot)
            self.IngredientTypeDataSource = (snapshot.value as? NSDictionary)!
            self.IngredientTypeTableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return IngredientTypeDataSource.allKeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var sortedKeys = (IngredientTypeDataSource.allKeys as! [String]).sorted(by: <)
        let ingredientId = sortedKeys[indexPath.row]
        cell.textLabel?.text = IngredientTypeDataSource[ingredientId] as? String
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var sortedKeys = (IngredientTypeDataSource.allKeys as! [String]).sorted(by: <)
        performSegue(withIdentifier: "toIngredient", sender: sortedKeys[indexPath.row])
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ingredientsViewController = segue.destination as? IngredientsViewController{
            ingredientsViewController.ingredientId = sender as! String
        }
    }
}
