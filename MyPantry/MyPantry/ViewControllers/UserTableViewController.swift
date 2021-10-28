//
//  UserTableViewController.swift
//  MyPantry
//
//  Created by Giacomo Orsi on 10/06/2021.
//

import UIKit
import SPAlert

/// Shows the credentials of the user
class UserTableViewController: UITableViewController {
    
    let model = ServerModel.model
    
    /// If it is not null, it means that the user has run the app for the first time and he/she is doing the login for the first time
    var welcomeDelegate : WelcomeScreenCollectionViewController?
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
    }
    
    func reloadData() {
        emailField.text = model.email
        passwordField.text = model.password
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        if (emailField.text == "" || passwordField.text == ""){
            SPAlert.present(title: "Compila tutti i campi", preset:.error, haptic: .error)
            return
        }
        
        let alert = UIAlertController(title: nil, message: "Attendi...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true) {
            do {
                try self.model.checkLoginDetails(email: self.emailField.text!, password: self.passwordField.text!)
                self.model.email = self.emailField.text!
                self.model.password = self.passwordField.text!
                
                alert.dismiss(animated: true){
                    SPAlert.present(title: "Credenziali salvate", preset: .done, haptic: .success)
                    if self.welcomeDelegate != nil {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            } catch {
                alert.dismiss(animated: true) {
                    if case ServerModel.ServerModelError.loginError = error {
                        SPAlert.present(title: "Errore", message: "Le credenziali inserite non sono valide", preset: .error, completion: nil)
                    } else if case ServerModel.ServerModelError.connectionError = error {
                        SPAlert.present(title: "Errore di connessione", message: "Impossibile effettuare il login", preset: .error, completion: nil)
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "UserRegistration"){
            let navigation = segue.destination as! UINavigationController
            let vc = navigation.topViewController as! UserRegistrationTableViewController
            
            vc.delegate = self
        }
    }
}
