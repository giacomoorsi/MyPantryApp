//
//  UserRegistrationTableViewController.swift
//  MyPantry
//
//  Created by Giacomo Orsi on 10/06/2021.
//

import UIKit
import SPAlert

/// Shows a view which lets the user to sign-up on the collaborative database
class UserRegistrationTableViewController: UITableViewController {
    
    /// The view which called this view
    var delegate : UserTableViewController?
    
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) { self.dismiss(animated: true, completion: nil) }
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func userRegistrationButtonClicked(_ sender: UIBarButtonItem) {
        
        if (emailField.text  == "" || passwordField.text == "" || usernameField.text == "") {
            SPAlert.present(message: "Compila tutti i campi ", haptic: .error)
            return
        }
        
        let loadingAlert = UIAlertController(title: nil, message: "Attendi...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        loadingAlert.view.addSubview(loadingIndicator)
        present(loadingAlert, animated: true) {
            do {
                try ServerModel.model.register(email: self.emailField.text!, password: self.passwordField.text!, username: self.usernameField.text!)
                self.delegate!.reloadData()
                loadingAlert.dismiss(animated: true){
                    SPAlert.present(title: "Registrazione completata", preset: .done, completion: nil)
                    self.dismiss(animated: true, completion: nil)
                }
                
            } catch {
                loadingAlert.dismiss(animated: false){
                    if case ServerModel.ServerModelError.connectionError = error {
                        SPAlert.present(title: "Errore", message: "Si è verificato un errore di connesisone", preset: .error, completion: nil)
                    } else if case ServerModel.ServerModelError.registrationError = error  {
                        SPAlert.present(title: "Errore", message: "Si è verificato un errore in fase di registrazione. Non è possibile registrarsi più volte con lo stesso indirizzo email o username", preset: .error, completion: nil)
                    }
                }
            }
        }
    }
}
