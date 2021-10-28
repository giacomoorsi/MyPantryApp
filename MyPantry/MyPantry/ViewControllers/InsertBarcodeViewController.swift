//
//  InsertBarcodeViewController.swift
//  MyPantry
//
//  Created by Giacomo Orsi on 19/05/2021.
//

import UIKit
import SPAlert

/// Shows a view which allows the user to insert a barcode manually
class InsertBarcodeViewController: UIViewController {
    
    var serverModel = ServerModel.model
    
    @IBOutlet weak var barcodeTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    var products : [ServerModel.Product]?
    var seguePerformed = false // evito che se l'utente torna indietro sulla view avvenga il segue automatico
    
    /// It can be set by the previous view
    var barcode : String?
    
    override func viewDidAppear(_ animated: Bool) {
        if(barcode != nil){
            barcodeTextField.text = barcode
            
            if(seguePerformed == false){
                searchBarcode()
            }
        }
    }
    
    
    @IBAction func searchBarcode(_ sender: UIButton) {
        searchBarcode()
    }
    
    func searchBarcode(){
        let alert = UIAlertController(title: nil, message: "Attendi...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true){
            do {
                try self.products = self.serverModel.searchProducts(withBarcode: self.barcodeTextField.text!)
                alert.dismiss(animated: true){
                    self.performSegue(withIdentifier: "SearchByBarcode", sender: nil)
                }
            } catch {
                alert.dismiss(animated: true)
                SPAlert.present(title: "Errore", message: "Spiacenti, si è verificato un errore di connessione al server", preset: .error, completion: nil)
            }
        }
    }
    
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "SearchByBarcode" {
            return false
        }
        return true
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SearchByBarcode"){
            let vc = segue.destination as! SearchProductsByBarcodeTableViewController
            vc.barcode = barcodeTextField.text!
            vc.products = products!
            vc.serverModel = serverModel
            
            seguePerformed = true
        }
    }
}
