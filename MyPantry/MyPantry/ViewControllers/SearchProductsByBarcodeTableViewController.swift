//
//  SearchProductsByBarcodeTableViewController.swift
//  MyPantry
//
//  Created by Giacomo Orsi on 19/05/2021.
//

import UIKit

/// A cell which shows a product on the collaborative database
class ProductTableCell : UITableViewCell {
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    @IBAction func infoButtonPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: product?.name, message: product?.description, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Chiudi", style: UIAlertAction.Style.cancel, handler: nil))
        
        tableView?.present(alert, animated: true, completion: nil)
        
        
    }
    var barcode: String?
    var product : ServerModel.Product?
    var tableView : UITableViewController?
}


/// Shows a list of product which has been found on the collaborative database for a certain barcode
class SearchProductsByBarcodeTableViewController: UITableViewController {
    
    var serverModel = ServerModel.model
    var barcode : String = ""
    var products = [ServerModel.Product]()
    var selectedProduct : ServerModel.Product?
    
    @IBOutlet weak var pageTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(products.count == 0) {
            pageTitleLabel.text = "Nessun prodotto trovato. Fai clic sul + per aggiungerne uno nuovo"
            
        } else {
            pageTitleLabel.text = "Sono stati trovati dei prodotti corrispondenti al barcode inserito. Scegli quello che corrisponde al tuo prodotto. Se nessuno corrisponde al tuo prodotto, clicca sul + per aggiungerne uno nuovo."
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:ProductTableCell? = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductTableCell
        
        cell?.productTitle.text = products[indexPath.row].name
        cell?.productDescription.text = products[indexPath.row].description
        cell?.product = products[indexPath.row]
        cell?.barcode = barcode
        cell?.tableView = self
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedProduct = products[indexPath.row]
        performSegue(withIdentifier: "CompleteProductInformation", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigation = segue.destination as! UINavigationController
        let vc = navigation.topViewController as! InsertProductTableViewController
        
        vc.viewDelegate = self
        if (segue.identifier == "CompleteProductInformation"){
            vc.selectedProduct = selectedProduct
        }
        vc.barcode = barcode
    }
}
