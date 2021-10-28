//
//  HomeTableViewController.swift
//  MyPantry
//
//  Created by Giacomo Orsi on 09/05/2021.
//

import UIKit

/// Shows the home of MyPantry
class HomeTableViewController: UITableViewController {
    let model = MyPantryModel.model
    
    
    @IBOutlet weak var numberOfProductsInPantryLabel: UILabel!
    @IBOutlet weak var numberOfExpiringProductsLabel: UILabel!
    @IBOutlet weak var numberOfExpiredProductsLabel: UILabel!
    @IBOutlet weak var expiringStackView: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberOfProductsInPantryLabel.text = String(model.products.count)
        numberOfExpiringProductsLabel.text = String(model.getExpiringProducts().count)
        numberOfExpiredProductsLabel.text = String(model.getExpiredProducts().count)
        
        if !model.welcomeCompleted {
            performSegue(withIdentifier: "ShowWelcomeScreen", sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        numberOfProductsInPantryLabel.text = String(model.products.count)
        numberOfExpiringProductsLabel.text = String(model.getExpiringProducts().count)
        numberOfExpiredProductsLabel.text = String(model.getExpiredProducts().count)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier != "ShowWelcomeScreen"){
            if (segue.identifier == "ProductsByCategory"){
                let vc = segue.destination as! CategoriesTableViewController
                vc.showProductsByCategory = true
            } else if segue.identifier == "ProductsByPantry" {
                let vc = segue.destination as! PantriesTableViewController
                vc.showProductsByPantry = true
            } else {
                
                let vc = segue.destination as! ProductsTableViewController
                switch(segue.identifier) {
                case "AllProducts" :
                    vc.products = {
                        return self.model.products
                    }
                    vc.pageTitle = "I tuoi prodotti"
                case "OpenedProducts" :
                    vc.products = {
                        return self.model.getOpenedProducts()
                    }
                    vc.pageTitle = "Prodotti aperti"
                case "ExpiredProducts" :
                    vc.products = {
                        return self.model.getExpiredProducts()
                    }
                    vc.pageTitle = "Prodotti scaduti"
                case "ExpiringProducts" :
                    vc.products = {
                        return self.model.getExpiringProducts()
                    }
                    vc.pageTitle = "Prodotti in scadenza"
                case "ConsumedProducts" :
                    vc.products = {
                        return self.model.getConsumedProducts()
                    }
                    vc.pageTitle = "Prodotti consumati"
                case .none:
                    break
                case .some(_):
                    break
                }
            }
        }
    }
}
