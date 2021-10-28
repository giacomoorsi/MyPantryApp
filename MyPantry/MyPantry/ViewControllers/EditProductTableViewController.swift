//
//  EditProductTableViewController.swift
//  MyPantry
//
//  Created by Giacomo Orsi on 25/05/2021.
//

import UIKit
import SPAlert

/// Shows a page where the user edit a `PantryItem`
class EditProductTableViewController: UITableViewController, ProductPageProtocol {
    
    var model = MyPantryModel.model
    var productsListVC : ProductsTableViewController?
    
    /// Product to be modified
    var product : PantryItem?
    
    
    
    @IBOutlet weak var selectedCategoryName: UILabel!
    @IBOutlet weak var selectedPantryName: UILabel!
    @IBOutlet weak var expireDatePicker: UIDatePicker!
    @IBAction func expireDateToggle(_ sender: UISwitch) {
        if sender.isOn {
            expireDatePicker.isEnabled = true
        } else {
            expireDatePicker.isEnabled = false
        }
    }
    
    
    @IBOutlet weak var consumeProductLabel: UILabel!
    @IBOutlet weak var openProductLabel: UILabel!
    @IBOutlet weak var deleteProductLabel: UILabel!
    
    @IBOutlet weak var consumeProductImage: UIImageView!
    @IBOutlet weak var openProductImage: UIImageView!
    @IBOutlet weak var deleteProductImage: UIImageView!
    
    
    @IBOutlet weak var expireDateToggle: UISwitch!
    @IBOutlet weak var barcodeLabel: UILabel!
    @IBOutlet weak var addProductButton: UIBarButtonItem!
    @IBOutlet weak var productNameField: UITextField!
    @IBAction func dismissView(_ sender: Any) {
        model.rollback()
        self.dismiss(animated: true, completion: nil)
    }
    var productName : String? { get { return productNameField?.text } }
    var productExpireDate : Date? {
        get {
            if expireDatePicker.isEnabled == false {
                return nil
            } else {
                return expireDatePicker.date
            }
        }
    }
    var selectedCategory : Category? {
        get {   return product?.category }
        set {   product?.category = newValue }
    }
    var selectedPantry : Pantry? {
        get { return product?.pantry }
        set { product?.pantry = newValue }
    }
    var productDescription: String? {
        get { return product?.productDescription }
        set { product?.productDescription = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (product == nil){
            fatalError("Il prodotto non può essere nullo")
        }
        selectedCategoryName.text = product!.category?.name
        selectedPantryName.text = product!.pantry?.name
        barcodeLabel.text = product!.barcode
        
        if product?.expireDate != nil {
            expireDatePicker.date = product!.expireDate!
            expireDateToggle.isOn = true
        } else {
            expireDateToggle.isOn = false
            expireDatePicker.isEnabled = false
        }
        
        productNameField.text = product?.name
        
        if product?.consumed == true {
            consumeProductLabel.text = "Contrassegna come non consumato"
            consumeProductImage.image = UIImage(systemName: "xmark.circle")
        }
        
        if product?.opened == true {
            openProductLabel.text = "Contrassegna come chiuso"
            openProductImage.image = UIImage(systemName: "lock")
        }
        
        
        // Fix datePicker alignment
        expireDatePicker.semanticContentAttribute = .forceRightToLeft
        expireDatePicker.subviews.first?.semanticContentAttribute = .forceRightToLeft
        
    }
    
    @IBAction func editProduct(_ sender: Any) {
        do {
            product!.name = productName!
            
            if expireDateToggle.isOn {
                product!.expireDate = expireDatePicker.date
            } else {
                product!.expireDate = nil
            }
            
            product!.productDescription = productDescription
            
            model.commit()
            model.removeNotificationsFor(product: product!)
            model.setNotificationsFor(product: product!)
            
            productsListVC!.updateTableData()
            dismiss(animated: true, completion: nil)
            
        } catch {
            print("errore. Non tutti i campi sono compilati")
            model.rollback()
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 3 {
            if indexPath.row == 0 {
                model.consume(product: product!)
                
                if(product?.consumed == true) {
                    SPAlert.present(title: "Consumato", message: "Il prodotto è stato inserito nell'archivio", preset: .custom(UIImage(systemName: "archivebox")!))
                } else {
                    SPAlert.present(title: "Non consumato", message: "Il prodotto è stato rimosso dall'archivio", preset: .custom(UIImage(systemName: "xmark.circle")!))
                }
                
            } else if indexPath.row == 1 {
                model.open(product: product!)
                if(product?.opened == true) {
                    SPAlert.present(title: "Aperto", message: "Il prodotto è inserito tra i prodotti aperti", preset: .custom(UIImage(systemName: "lock.open")!))
                } else {
                    SPAlert.present(title: "Non aperto", message: "Il prodotto è stato rimosso dai prodotti aperti", preset: .custom(UIImage(systemName: "lock")!))
                }
                
                
                model.commit()
                
            } else if indexPath.row == 2 {
                
                SPAlert.present(title: "Eliminato", message: "Il prodotto è stato eliminato", preset: .custom(UIImage(systemName: "trash")!))
                model.remove(product: product!)
                
            } else if indexPath.row == 3 {
                
                SPAlert.present(title: "Aggiunto alla lista", message: "Il prodotto è stato aggiunto alla lista della spesa", preset: .custom(UIImage(systemName: "cart")!))
                
                model.add(shoppingListItemFromPantryItem: product!)
                
            }
            productsListVC!.updateTableData()
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChooseCategory" {
            let presentedVC = segue.destination as! ChooseCategoryOrPantryTableViewController
            presentedVC.whatToChoose = .category
            presentedVC.delegate = self
            //present(presentedVC, animated: true, completion: nil)
        } else if  segue.identifier == "ChoosePantry" {
            let presentedVC = segue.destination as! ChooseCategoryOrPantryTableViewController
            presentedVC.whatToChoose = .pantry
            presentedVC.delegate = self
            //present(presentedVC, animated: true, completion: nil)
        } else if segue.identifier == "InsertProductDescription" {
            let presentedVC = segue.destination as! InsertProductDescriptionTableViewController
            presentedVC.delegate = self
            presentedVC.productDescription = productDescription
        }
    }
    
    // Called by Choose(Category|Pantry)TableViewController
    func selectCategory(category: Category) {
        selectedCategory = category
        selectedCategoryName.text = category.name
    }
    
    // Called by Choose(Category|Pantry)TableViewController
    func selectPantry(pantry: Pantry) {
        selectedPantry = pantry
        selectedPantryName.text = pantry.name
    }
}
