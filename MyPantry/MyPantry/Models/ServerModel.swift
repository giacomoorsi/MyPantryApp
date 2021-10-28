//
//  ServerModel.swift
//  MyPantry
//
//  Created by Giacomo Orsi on 19/05/2021.
//

import Foundation

/*
 If needed, it is possible to use these credentials:
 username = "apo"
 email = "giacomo.orsi2@studio.unibo.it"
 password = "LAMProject2021"
 */

/// Handles the connection between MyPantry and the collaborative database
class ServerModel {
    static let model = ServerModel() // singleton
    let defaults = MyPantryModel.model.defaults // user preferences
    
    
    
    /// if set to yes, the products uploaded to the collaborative database will not be saved
    private let testMode = true
    
    /// stores an accesssToken for a user
    private var accessToken : String?
    
    /// stores the sessionToken for a barcode search
    private var sessionToken : String?
    
    /// The API documentation can be found here: https://lam21.modron.network/explorer/#/
    struct urls {
        static let login = "https://lam21.modron.network/auth/login"
        static let products = "https://lam21.modron.network/products"
        static let votes = "https://lam21.modron.network/votes"
        static let registration = "https://lam21.modron.network/users"
    }
    
    /// A product on the collaborative database
    struct Product : Codable {
        let id : String
        let name : String
        let description : String
        let barcode : String
        let userId : String
        let test : Bool
        let createdAt : String
        let updatedAt : String
        init(dictionary: [String: Any]) throws {
                self = try JSONDecoder().decode(Product.self, from: JSONSerialization.data(withJSONObject: dictionary))
        }
    }
    
    /// A set of error which may be raised during the connection with the remote server
    enum ServerModelError : Error {
        case loginError
        case connectionError
        case registrationError
    }
    
    var username : String? {
        get {  return defaults.string(forKey: "username") }
        set { defaults.setValue(newValue, forKey: "username") }
    }
    var password : String? {
        get { return defaults.string(forKey: "password") }
        set { defaults.setValue(newValue, forKey: "password") }
    }
    var email : String? {
        get { return defaults.string(forKey: "email") }
        set { defaults.setValue(newValue, forKey: "email") }
    }
    var registered : Bool { get { email != nil && password != nil } }
    
    /// Tries to login on the collaborative database
    func login() throws {
        
        if !registered  {
            throw ServerModelError.loginError
        }
        let url = URL(string: urls.login)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: String] = [
            "email": email!,
            "password": password!
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        request.timeoutInterval = 20
        
        let semaphore = DispatchSemaphore(value: 0)
        var loginError : Error?
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                if let httpResponse = response as? HTTPURLResponse {
                    if (httpResponse.statusCode != 201) {
                        loginError = ServerModelError.loginError
                    }
                }
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    let response = json as! [String : String]
                    self.accessToken = response["accessToken"]!
                } catch {
                    print(error)
                    loginError = error
                }
            }
            semaphore.signal()

        }.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        if(loginError != nil){
            throw loginError!
        }
    }
    
    /**
     Searches a barcode on the collaborative database
     - Parameter barcode: The barcode to be searched
     - Throws `ServerModelError`
     - Returns the list for products on the server
     */
    func searchProducts(withBarcode barcode: String) throws ->  [Product] {
        if (accessToken == nil){
            try login()
        }
                
        let url = URL(string: urls.products + "?barcode=" + barcode)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + accessToken!, forHTTPHeaderField: "Authorization")
        
        request.timeoutInterval = 20
        
        let session = URLSession.shared
        
        var products = [Product]()
        var connectionError : Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                //print("Response: \(response)\n\n")
            }
            connectionError = error
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    let response = json as! [String: Any]
                    if let error = response["message"] as? String {
                        fatalError(response["message"] as! String)
                    }
                    
                    
                    print("Response : \(response) ")
                    self.sessionToken = response["token"] as! String
                    
                    let products_list = response["products"] as! [[String:Any]]
                    print("Products_list : \(products_list) ")

                    for product in products_list {
                        products.append(try Product(dictionary: product))
                    }
                    print("Products:  : \(products) ")

                } catch {
                    connectionError = error
                }
            }
            
            semaphore.signal()

        }.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        if (connectionError != nil){
            print(connectionError)
            throw connectionError!
        }
        
        return products
    }
    
    
    /**
     Adds a new product on the collaborative database
     - Parameter item: the new product
     */
    func pushNewPantryItem(newProduct item : PantryItem){
        
        let url = URL(string: urls.products)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + accessToken!, forHTTPHeaderField: "Authorization")

        
        let parameters: [String: Any] = [
            "token": sessionToken!,
            "name": item.name!,
            "description": item.productDescription ?? "",
            "barcode": item.barcode!,
            "test": testMode
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.timeoutInterval = 20
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
               print("Response: \(response)\n\n")
                if let httpResponse = response as? HTTPURLResponse {
                    print("pushNewPantryItem response status code: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
    
    /**
     Notifies the collaborative database about the choice made by the user
     - Parameter preference: the chosen product
     */
    func pushProductPreference(preference: ServerModel.Product) {
        let url = URL(string: urls.votes)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + accessToken!, forHTTPHeaderField: "Authorization")

        
        let parameters: [String: Any] = [
            "token": sessionToken!,
            "rating": 1,
            "productId": preference.id
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.timeoutInterval = 20
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
               print("Response: \(response)\n\n")
                if let httpResponse = response as? HTTPURLResponse {
                    print("pushProductPreference response status code: \(httpResponse.statusCode)")
                    if(httpResponse.statusCode == 201){
                        print("Preferenza inviata con successo")
                    } else {
                        print("Errore nell'invio della preferenza")
                    }
                }
            }
            
        }.resume()
    }
    
    /**
     Checks on the remote server if the email and the password inserted are valid
     - Parameters:
     - email: the email to be checked
     - password: the password to be checked
     - Throws `ServerModelError`
     */
    func checkLoginDetails(email: String, password: String) throws {
        let url = URL(string: urls.login)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: String] = [
            "email": email,
            "password": password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.timeoutInterval = 20
        let semaphore = DispatchSemaphore(value: 0)
        var loginError : Error?
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                if let httpResponse = response as? HTTPURLResponse {
                    if (httpResponse.statusCode != 201) {
                        loginError = ServerModelError.loginError
                    }
                }
            }
            if let error = error {
                loginError = error
            }
            
            semaphore.signal()

        }.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        if (loginError != nil) {
            throw loginError!
        }
    }
    
    /**
     Registeres a new user on the collaborative database
     - Parameters:
     - email: email of the new user
     - password: password of the new user
     - username: username chosen by the new user
     - Throws `ServerModelError`
     */
    func register(email: String, password: String, username: String) throws {
        let url = URL(string: urls.registration)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String:String] = [
            "username": username,
            "email": email,
            "password": password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.timeoutInterval = 20
        
        let session = URLSession.shared
        
        var connectionError : Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                if let httpResponse = response as? HTTPURLResponse {
                    if (httpResponse.statusCode == 500) {
                        connectionError = ServerModelError.registrationError
                    }
                }
            }
            if (error != nil){
                connectionError = error
            }
            if let data = data {
                if (connectionError != nil) {
                    self.username = username
                    self.password = password
                    self.email = email
                }
            }
            semaphore.signal()

        }.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        if (connectionError != nil){
            print(connectionError)
            throw connectionError!
        }
    }
}
