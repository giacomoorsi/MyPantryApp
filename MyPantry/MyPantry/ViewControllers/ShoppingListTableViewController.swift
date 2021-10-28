//
//  ShoppingListTableViewController.swift
//  MyPantry
//
//  Created by Giacomo Orsi on 29/05/2021.
//

import UIKit

/// Shows an item in the shopping list
class ShoppingListTableCell : UITableViewCell {
    @IBOutlet weak var productCategoryLabel: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    var shoppingListItem : ShoppingListItem?
}

/// Shows a list of items in the shopping list
class ShoppingListTableViewController: UITableViewController {
    
    let model = MyPantryModel.model
    
    var shoppingListItems : [ShoppingListItem]?
    @IBOutlet weak var pageDescriptionLabel: UITextView!
    
    @IBOutlet weak var emptyLabelView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingListItems!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListTableCell")
        
        let shoppingListCell = cell as! ShoppingListTableCell
        
        shoppingListCell.shoppingListItem = shoppingListItems![indexPath.row]
        
        if let categoryName = shoppingListItems![indexPath.row].category?.name {
            shoppingListCell.productCategoryLabel.text = categoryName
            shoppingListCell.categoryImage.isHidden = false
        } else {
            shoppingListCell.productCategoryLabel.text = ""
            shoppingListCell.categoryImage.isHidden = true
        }
        
        shoppingListCell.productNameLabel.text = shoppingListItems![indexPath.row].name
        
        return shoppingListCell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            model.remove(shoppingListItem: shoppingListItems![indexPath.row])
            shoppingListItems?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            print("eliminata riga")
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            print("aggiunta riga")
        }
    }
    
    func reloadData(){
        shoppingListItems = MyPantryModel.model.shoppingListItems
        tableView.reloadData()
        
        if(shoppingListItems?.count != 0){
            pageDescriptionLabel.text = "Puoi aggiungere un nuovo prodotto alla lista della spesa da quelli che hai nella dispensa. "
        } else {
            pageDescriptionLabel.text = "Non hai nessun prodotto nella tua lista della spesa. Puoi aggiungere un nuovo prodotto alla lista della spesa da quelli che hai nella dispensa. "
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "InsertProductFromShoppingList"){
            let navigation = segue.destination as! UINavigationController
            let vc = navigation.topViewController as!InsertProductTableViewController
            let selectedItem = shoppingListItems![tableView.indexPathForSelectedRow!.row]
            
            vc.selectedCategory = selectedItem.category
            vc.selectedPantry = selectedItem.pantry
            vc.productDescription = selectedItem.productDescription
            vc.barcode = selectedItem.barcode
            vc.productName = selectedItem.name
            vc.shoppingListItem = selectedItem
            vc.viewDelegate = self
            
            if vc.shoppingListItem?.category?.name == nil {
                vc.shoppingListItem?.category = nil
            }
            if vc.shoppingListItem?.pantry?.name == nil {
                vc.shoppingListItem?.pantry = nil
            }
        } else if (segue.identifier == "ChooseShoppingListItemFromProducts") {
            let navigation = segue.destination as! UINavigationController
            
            let vc = navigation.topViewController as! ShoppingListAddProductTableViewController
            vc.shoppingListVc = self
            
        }
    }
}
