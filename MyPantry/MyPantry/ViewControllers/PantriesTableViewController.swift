//
//  PantriesTableViewController.swift
//  MyPantry
//
//  Created by Giacomo Orsi on 09/05/2021.
//

import UIKit
import CoreData

/// Shows a list of the pantries and allows the user to add or remove pantries
class PantriesTableViewController: UITableViewController {
    
    lazy var model = MyPantryModel.model
    let context = AppDelegate.viewContext
    var showProductsByPantry = false
    var pantries = [Pantry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        pantries = model.pantries
    }
        
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pantries.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PantryCell", for: indexPath)
        cell.textLabel?.text = pantries[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var alert = UIAlertController(title: "Attenzione", message: "Verranno eliminati anche tutti i prodotti presenti nella dispensa. ", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                self.model.remove(pantry: self.pantries[indexPath.row])
                self.pantries = self.model.pantries
                tableView.deleteRows(at: [indexPath], with: .fade)
            }))
            
            alert.addAction(UIAlertAction(title: "Annulla", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            
            present(alert, animated: true, completion: nil)
            
        } else if editingStyle == .insert {
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !showProductsByPantry {
            return
        } else {
            performSegue(withIdentifier: "ShowProductsByPantry", sender: nil)
        }
    }
    
    @IBAction func addPantry(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Aggiungi una dispensa", message: "Inserisci il nome della dispensa.", preferredStyle: .alert)
        alert.addTextField { (UITextField) in
            
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if let newPantryName = textField!.text {
                self.model.add(pantryWithName: newPantryName)
                self.pantries = self.model.pantries
                self.tableView.reloadData()
                
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Annulla", style: .cancel))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowProductsByPantry" {
            let vc = segue.destination as! ProductsTableViewController
            let selectedPantry = pantries[tableView.indexPathForSelectedRow!.row]
            vc.pageTitle = selectedPantry.name
            vc.products = {
                return self.model.getProductsBy(pantry: selectedPantry)
            }
        }
    }
}
