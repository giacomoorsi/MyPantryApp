//
//  InsertProductTableViewController.swift
//  MyPantry
//
//  Created by Giacomo Orsi on 19/05/2021.
//

import UIKit
import SPAlert

/// Shows a view which lets the user to insert a new product in MyPantry
class InsertProductTableViewController: UITableViewController, ProductPageProtocol {
    
    let model = MyPantryModel.model
    
    @IBOutlet weak var barcodeLabel: UILabel!
    @IBOutlet weak var selectedCategoryName: UILabel!
    @IBOutlet weak var selectedPantryName: UILabel!
    @IBOutlet weak var expireDatePicker: UIDatePicker!
    @IBAction func expireDateToggle(_ sender: UISwitch) { expireDatePicker.isEnabled = sender.isOn }
    @IBOutlet weak var addProductButton: UIBarButtonItem!
    @IBOutlet weak var productNameField: UITextField!
    @IBAction func dismissView(_ sender: Any) { self.dismiss(animated: true, completion: nil) }
    
    
    var selectedCategory : Category?
    var selectedPantry : Pantry?
    var selectedProduct : ServerModel.Product?
    var serverModel : ServerModel = ServerModel.model
    var productDescription : String?
    var productName : String?
    
    var productExpireDate : Date? {
        get {
            if expireDatePicker.isEnabled == false {
                return nil
            } else {
                return expireDatePicker.date
            }
        }
    }
    var barcode : String?
    var shoppingListItem : ShoppingListItem?
    var viewDelegate : UIViewController?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if (selectedProduct != nil) {
            productNameField.text = selectedProduct!.name
            productNameField.isEnabled = false
            productDescription = selectedProduct!.description
        }
        
        if (selectedCategory != nil) {
            selectedCategoryName.text = selectedCategory?.name
        }
        
        if (selectedPantry != nil) {
            selectedPantryName.text = selectedPantry?.name
        }
        
        if (productName != nil) {
            productNameField.text = productName
        }
        
        if (barcode != nil) {
            barcodeLabel.text = barcode
        } else {
            fatalError("Barcode missing")
        }
        
        expireDatePicker.isEnabled = false
       
        
        
        enableOrDisableAddProductButton()
        
        // Fix datePicker alignment
        expireDatePicker.semanticContentAttribute = .forceRightToLeft
        expireDatePicker.subviews.first?.semanticContentAttribute = .forceRightToLeft
        
    }
    
    
    func enableOrDisableAddProductButton(){
        if(selectedPantry != nil && selectedCategory != nil && productNameField.text != nil){
            addProductButton.isEnabled = true
        } else {
            addProductButton.isEnabled = false
        }
    }
    
    @IBAction func addProduct(_ sender: UIBarButtonItem) {
        let newProduct = model.addPantryItem(name: productNameField.text!, productDescription: productDescription, expireDate: productExpireDate, category: selectedCategory, pantry: selectedPantry, barcode: barcode!)
        if (shoppingListItem != nil){
            model.remove(shoppingListItem: shoppingListItem!)
        }
        if (shoppingListItem == nil && selectedProduct == nil){
            // ho creato un nuovo prodotto, che devo caricare sul server
            serverModel.pushNewPantryItem(newProduct: newProduct)
        } else if (selectedProduct != nil){
            serverModel.pushProductPreference(preference: selectedProduct!)
        }
        
        SPAlert.present(title: "Prodotto aggiunto", message: "Il prodotto è stato aggiunto alla dispensa", preset: .done, completion: nil)
        dismiss(animated: true, completion: {
            self.viewDelegate?.navigationController?.popToRootViewController(animated: true)
            if self.viewDelegate is ShoppingListTableViewController {
                (self.viewDelegate as! ShoppingListTableViewController).reloadData()
            }
        })
    }
    
    func selectCategory(category newSelectedCategory: Category){
        selectedCategory = newSelectedCategory
        selectedCategoryName.text = selectedCategory!.name
        enableOrDisableAddProductButton()
    }
    
    func selectPantry(pantry newSelectedPantry: Pantry){
        selectedPantry = newSelectedPantry
        selectedPantryName.text = selectedPantry!.name
        enableOrDisableAddProductButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ChooseCategory" {
            let presentedVC = segue.destination as! ChooseCategoryOrPantryTableViewController
            presentedVC.whatToChoose = .category
            presentedVC.delegate = self
        } else if  segue.identifier == "ChoosePantry" {
            let presentedVC = segue.destination as! ChooseCategoryOrPantryTableViewController
            presentedVC.whatToChoose = .pantry
            presentedVC.delegate = self
        } else if segue.identifier == "InsertProductDescription" {
            let presentedVC = segue.destination as! InsertProductDescriptionTableViewController
            presentedVC.delegate = self
            presentedVC.productDescription = productDescription
            if (selectedProduct != nil){
                presentedVC.canEditDescription = false
            }
        }
        
    }
    
}
