//
//  ChooseCategoryTableViewController.swift
//  MyPantry
//
//  Created by Giacomo Orsi on 18/05/2021.
//

import UIKit

/// Shows the categories or the pantries. The chosen one is returned to the `delegate`
class ChooseCategoryOrPantryTableViewController: UITableViewController {
    
    let model : MyPantryModel = MyPantryModel.model
    
    var categories = [Category]()
    var pantries = [Pantry]()
    
    enum Choice {
        case category, pantry
    }
    
    var whatToChoose : Choice?
    
    /// Controller which is notified of the choice made
    var delegate : ProductPageProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        switch whatToChoose {
        case .category : do {
            categories = model.categories
            self.title = "Categoria"
        }
        case .pantry : do {
            pantries = model.pantries
            self.title = "Dispensa"
        }
        case .none : fatalError("Errore, nessuna scelta effettuata")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = self.delegate {
            switch whatToChoose {
            case .category : delegate.selectCategory(category: categories[indexPath.row])
            case .pantry : delegate.selectPantry(pantry: pantries[indexPath.row])
            case .none:
                break
            }
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch whatToChoose {
        case .category : return categories.count
        case .pantry : return pantries.count
        case .none : return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        var label : String?
        switch whatToChoose {
        case .category :  label = categories[indexPath.row].name
            
        case .pantry :  label = pantries[indexPath.row].name
            
        case .none : label = ""
        }
        cell.textLabel?.text = label
        return cell
    }
}
