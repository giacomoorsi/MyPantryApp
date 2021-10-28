//
//  WelcomeScreenCollectionViewController.swift
//  MyPantry
//
//  Created by Giacomo Orsi on 10/06/2021.
//

import UIKit

/// Cell which contains a feature of MyPantry
class WelcomeScreenCell : UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconLabel: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
}

/// Shows a recap of the features of MyPantry for new users
class WelcomeScreenCollectionViewController: UICollectionViewController {
    @IBAction func dismissView(_ sender: Any) {
        // MyPantryModel.model.welcomeCompleted = true
        performSegue(withIdentifier: "Login", sender: nil)
    }
    
    struct WelcomeScreenItem {
        var title : String
        var description : String
        var image : String
    }
    
    /// Features of MyPantry
    var items : [WelcomeScreenItem] = [
        WelcomeScreenItem(title: "Categorie", description: "Tieni organizzati i tuoi prodotti in categorie completamente personalizzabili", image: "tag"),
        WelcomeScreenItem(title: "Dispense", description: "Specifica in quale area della casa hai posizionato i prodotti per ritrovarli velocemente", image: "tray"),
        WelcomeScreenItem(title: "Scadenze e notifiche", description: "Tieni traccia delle scadenze dei prodotti e ricevi notifiche quando un prodotto è in scadenza", image: "calendar"),
        WelcomeScreenItem(title: "Database collaborativo", description: "Scansiona il barcode dei prodotti e condividi la descrizione con gli altri utenti di MyPantry", image: "cloud"),
        WelcomeScreenItem(title: "Lista della spesa", description: "Inserisci i tuoi prodotti nella lista della spesa per non dimenticarti cosa acquistare", image: "cart")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MyPantryModel.model.initApplication()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader :
            
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "WelcomeScreenHeader", for: indexPath)
            
        case UICollectionView.elementKindSectionFooter :
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "WelcomeScreenFooter", for: indexPath)
            
        default:
            return UICollectionReusableView()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WelcomeScreenCell", for: indexPath)
        
        let item = items[indexPath.row]
        
        
        if let welcomeCell = cell as? WelcomeScreenCell {
            welcomeCell.titleLabel.text = item.title
            welcomeCell.descriptionLabel.text = item.description
            welcomeCell.iconLabel.image = UIImage(systemName: item.image)
            return welcomeCell
        } else {
            return cell
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Login" {
            let vc = segue.destination as! UserTableViewController
            vc.welcomeDelegate = self
        }
    }
}
