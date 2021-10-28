//
//  InsertProductDescriptionTableViewController.swift
//  MyPantry
//
//  Created by Giacomo Orsi on 22/05/2021.
//

import UIKit

/// Shows a view which can be used to insert or edit a `PantryItem` description
class InsertProductDescriptionTableViewController: UITableViewController, UITextViewDelegate {
    
    /// The controller which edits or creates a product
    var delegate : ProductPageProtocol?
    
    var productDescription : String?
    
    /// It is set to false for the products which are downloded from the collaborative database
    var canEditDescription = true
    
    @IBOutlet weak var productDescriptionField: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productDescriptionField.text = productDescription
        
        if (canEditDescription == false){
            productDescriptionField.isEditable = false
        }
        
        productDescriptionField.delegate = self
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.productDescription = textView.text
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
