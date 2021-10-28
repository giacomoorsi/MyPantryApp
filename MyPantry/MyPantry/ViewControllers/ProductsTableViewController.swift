//
//  ProductsTableViewController.swift
//  MyPantry
//
//  Created by Giacomo Orsi on 23/05/2021.
//

import UIKit
import SPAlert


/// A cell which contains information about the product
class ProductCell : UITableViewCell {
    
    @IBOutlet weak var pantryImage: UIImageView!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var expireLabel: UILabel!
    @IBOutlet weak var expireClock: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var pantryLabel: UILabel!
    @IBOutlet weak var openClosedImage: UIImageView!
    var product : PantryItem?
}

/// Shows a list of products
class ProductsTableViewController: UITableViewController, UISearchBarDelegate {
    
    let model = MyPantryModel.model
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noProductsView: UIView!
    @IBOutlet weak var headerView: UIView!
    
    /**
     A function which can be evalueted to retrieve the correct products
     */
    var products : (() -> [PantryItem]?) = {
        return nil
    }
    var pageTitle : String?
    
    /// The products which have been filtered by the `searchBar`
    var filteredProducts : [PantryItem]?
    
    /// Used to optimize search and avoid an access on the database every time the user changes the text in the `searchBar`
    var cachedProducts : [PantryItem]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Used to always show the searchBar
        self.tableView.contentOffset = CGPoint(x: 0, y: searchBar.frame.size.height)

        headerView.frame = CGRect(x: 0, y: 0, width: CGFloat(0), height: headerView.frame.height)
        searchBar.delegate = self
        updateTableData()
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProducts!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        
        let productCell = cell as! ProductCell
        let product = filteredProducts![indexPath.row]
        productCell.nameLabel.text = product.name
        
        if let categoryName = product.category?.name {
            productCell.categoryLabel.text = categoryName
            productCell.categoryImage.isHidden = false
        } else {
            productCell.categoryLabel.text = ""
            productCell.categoryImage.isHidden = true
        }
        
        if let pantryName = product.pantry?.name {
            productCell.pantryLabel.text = pantryName
            productCell.pantryImage.isHidden = false
        } else {
            productCell.pantryLabel.text = ""
            productCell.pantryImage.isHidden = true
        }
        
        if let expireDate = product.expireDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            productCell.expireLabel.text = formatter.string(from: expireDate)
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date.init())
            let expiringDate = calendar.date(byAdding: .day, value: model.expiringThreshold, to: Date.init())
            
            if expireDate < expiringDate! && expireDate >= today {
                productCell.expireLabel.textColor = UIColor.systemOrange
                productCell.expireClock.tintColor = UIColor.systemOrange
            } else if  expireDate < today {
                productCell.expireLabel.textColor = UIColor.systemRed
                productCell.expireClock.tintColor = UIColor.systemRed
            } else {
                productCell.expireLabel.textColor = UIColor.darkGray
                productCell.expireClock.tintColor = UIColor.darkGray
            }
            
        } else {
            productCell.expireLabel.text = "Scadenza non disponibile"
            productCell.expireLabel.textColor = UIColor.darkGray
            productCell.expireClock.tintColor = UIColor.darkGray
        }
        if !product.opened {
            productCell.openClosedImage.image = UIImage(systemName: "lock")
        } else {
            productCell.openClosedImage.image = UIImage(systemName: "lock.open")
        }
        
        return cell
    }
    
    func updateTableData() {
        self.title = pageTitle
        filteredProducts = products()
        cachedProducts = filteredProducts
        if cachedProducts?.count == 0 || cachedProducts == nil {
            noProductsView.isHidden = false
            searchBar.isHidden = true
            //let header = self.tableView.tableHeaderView
            //self.tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: CGFloat(0), height: CGFloat(0))

            noProductsView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: noProductsView.frame.height)
            //headerView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: noProductsView.frame.height)
            self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            
        } else {
            noProductsView.isHidden = true
            searchBar.isHidden = false
            headerView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: searchBar.frame.height)
            
        }
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredProducts = cachedProducts
        } else {
            filteredProducts = cachedProducts?.filter {
                product in return product.name?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditProduct" {
            let navigation = segue.destination as! UINavigationController
            let vc = navigation.topViewController as! EditProductTableViewController
            vc.productsListVC = self
            vc.product = filteredProducts![tableView.indexPathForSelectedRow!.row]
        }
    }
}
