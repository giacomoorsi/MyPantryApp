//
//  SettingsTableViewController.swift
//  MyPantry
//
//  Created by Giacomo Orsi on 09/05/2021.
//

import UIKit
import SPAlert

/// Shows a view which allows the user to change MyPantry prefererences
class SettingsTableViewController: UITableViewController {
    let model = MyPantryModel.model
    
    let center = UNUserNotificationCenter.current()
    
    var defaults : UserDefaults?
    
    var notificationsPermissionGranted : Bool?
    
    @IBOutlet weak var expiringThresholdLabel: UILabel!
    
    @IBOutlet weak var notificationsSwift: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaults = model.defaults
        expiringThresholdLabel.text = String(model.expiringThreshold) + " giorni"
        updateNotificationSwitch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        center.getNotificationSettings { (settings) in
            if(settings.authorizationStatus == .notDetermined){
                print("Autorizzazione sulle notifiche non determinata")
                self.notificationsPermissionGranted = nil
            } else if (settings.authorizationStatus == .denied) {
                print("Autorizzazione non concessa")
                self.notificationsPermissionGranted = false
            } else {
                self.notificationsPermissionGranted = true
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 2 && indexPath.row == 1){
            let alert = UIAlertController(title: "Soglia prodotti in scadenza", message: "Inserisci il numero di giorni antecedenti la data di scadenza del prodotto oltre i quali un prodotto deve essere considerato ``in scadenza``.", preferredStyle: .alert)
            alert.addTextField { (UITextField) in
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    let textField = alert?.textFields![0]
                    if let newThreshold = textField!.text {
                        if (Int(newThreshold) ?? 0) != 0 {
                            self.model.expiringThreshold = Int(newThreshold)!
                            self.expiringThresholdLabel.text = String(self.model.expiringThreshold) + " giorni"
                        } else {
                            SPAlert.present(title: "Errore", message: "Inserisci un numero superiore a zero.", preset: .error, completion: nil)
                        }
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Annulla", style: .cancel))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    @IBAction func changeNotificationPreference(_ sender: UISwitch) {
        
        
        if(sender.isOn) {
            if(notificationsPermissionGranted == nil){
                center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                    if let error = error {
                        print("errore nella richiesta di notifiche")
                    }
                    self.notificationsPermissionGranted = granted
                    
                }
            } else if (notificationsPermissionGranted! == false){
                SPAlert.present(title: "Errore", message: "Non hai autorizzato MyPantry ad inviarti delle notifiche. Accedi alle impostazioni di iOS per autorizzare MyPantry.", preset: .error, completion: nil)
                sender.isOn = false
            } else if (notificationsPermissionGranted! == true){
                SPAlert.present(title: "Notifiche abilitate", message: "MyPantry ti avviserà quando i tuoi prodotti saranno in scadenza. ", preset: .done, completion: nil)
            }
        }
        
        
        self.defaults?.setValue(sender.isOn, forKey: "notificationsEnabled")
        
        // Cancello tutte le notifiche già programmate
        if (sender.isOn == false){
            center.removeAllPendingNotificationRequests()
        }
    }
    
    func updateNotificationSwitch(){
        if ((defaults?.bool(forKey: "notificationsEnabled")) != nil) {
            notificationsSwift.isOn = (defaults?.bool(forKey: "notificationsEnabled"))!
        } else {
            notificationsSwift.isOn = false
        }
    }
}
