//
//  CategoriesTableViewController.swift
//  MyPantry
//
//  Created by Giacomo Orsi on 09/05/2021.
//

import UIKit
import CoreData

/// Shows a list of the categories and allows the user to add or remove categories 
class CategoriesTableViewController: UITableViewController {
    
    lazy var model = MyPantryModel.model
    let context = AppDelegate.viewContext
    var categories = [Category]()
    
    /// if it is set to true, allows the user to click on a category and shows the list of products in that category
    var showProductsByCategory = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        categories = model.categories
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var alert = UIAlertController(title: "Attenzione", message: "Verranno eliminati anche tutti i prodotti associati alla categoria. ", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                self.model.remove(category: self.categories[indexPath.row])
                self.categories = self.model.categories
                tableView.deleteRows(at: [indexPath], with: .fade)
            }))
            
            alert.addAction(UIAlertAction(title: "Annulla", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            
            present(alert, animated: true, completion: nil)
            
        } else if editingStyle == .insert {
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !showProductsByCategory {
            return
        } else {
            performSegue(withIdentifier: "ShowProductsByCategory", sender: nil)
        }
    }
    
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Aggiungi una categoria", message: "Inserisci il nome della categoria.", preferredStyle: .alert)
        alert.addTextField { (UITextField) in
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if let newCategoryName = textField!.text {
                self.model.add(categoryWithName: newCategoryName)
                self.categories = self.model.categories
                self.tableView.reloadData()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Annulla", style: .cancel))
        
        self.present(alert, animated: true, completion: nil)
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowProductsByCategory" {
            let vc = segue.destination as! ProductsTableViewController
            let selectedCategory = categories[tableView.indexPathForSelectedRow!.row]
            vc.pageTitle = selectedCategory.name
            vc.products = {
                return self.model.getProductsBy(category: selectedCategory)
            }
        }
    }
}
