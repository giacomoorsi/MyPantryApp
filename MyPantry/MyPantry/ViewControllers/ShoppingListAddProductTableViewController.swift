//
//  ShoppingListAddProductTableViewController.swift
//  MyPantry
//
//  Created by Giacomo Orsi on 11/06/2021.
//

import UIKit
import SPAlert

class ProductCellForShoppingList : UITableViewCell {
    
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var product : PantryItem?
}


/// Shows all the products available in the pantry and gives the possibility to add them to the shopping list
class ShoppingListAddProductTableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    let model = MyPantryModel.model
    var products = [PantryItem]()
    var filteredProducts = [PantryItem]()
    
    var shoppingListVc : ShoppingListTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        products = model.products
        filteredProducts = products
        searchBar.delegate = self
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProducts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        let productCell = cell as! ProductCellForShoppingList
        let product = filteredProducts[indexPath.row]
        
        productCell.product = product
        productCell.nameLabel.text = product.name
        
        if let category = product.category {
            productCell.categoryImage.isHidden = false
            productCell.categoryLabel.text = category.name
        } else {
            productCell.categoryLabel.text = ""
            productCell.categoryImage.isHidden = true
        }

        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredProducts = products
        } else {
            filteredProducts = products.filter {
                product in return product.name?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = filteredProducts[indexPath.row]
        model.add(shoppingListItemFromPantryItem: product)
        shoppingListVc?.reloadData()
        self.dismiss(animated: true, completion: nil)
        SPAlert.present(title: "Aggiunto alla lista", message: "Il prodotto è stato aggiunto alla lista della spesa", preset: .custom(UIImage(systemName: "cart")!))
    }
    
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
