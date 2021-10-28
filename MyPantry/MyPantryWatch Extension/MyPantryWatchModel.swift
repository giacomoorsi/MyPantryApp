//
//  MyPantryWatchModel.swift
//  MyPantryWatch WatchKit Extension
//
//  Created by Giacomo Orsi on 29/05/2021.
//

import Foundation
import WatchConnectivity

/**
 The model for the Apple Watch app. It receives the messages from the iOS app and updates the ContentView
 */
class MyPantryWatchModel : NSObject,  WCSessionDelegate, ObservableObject {
    
    @Published var entry : MyPantryWatchEntry
    
    var session: WCSession
    var defaults : UserDefaults
    
    init(session: WCSession = .default){
        self.session = session
        self.defaults = UserDefaults()
        
        let numberOfExpiringProducts = defaults.value(forKey: "numberOfExpiringProducts") as? String ?? "..."
        let numberOfProductsInPantry = defaults.value(forKey: "numberOfExpiringProducts") as? String ?? "..."
        let numberOfExpiredProducts = defaults.value(forKey: "numberOfExpiringProducts") as? String ?? "..."
        
        self.entry = MyPantryWatchEntry(productsInPantry: numberOfProductsInPantry, expiredProducts: numberOfExpiredProducts, expiringProducts: numberOfExpiringProducts)
        
        super.init()
        self.session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if(message["numberOfExpiringProducts"] != nil){
                self.entry.expiringProducts = message["numberOfExpiringProducts"] as! String
                self.defaults.setValue(self.entry.expiringProducts, forKey: "numberOfExpiringProducts")
            } else if(message["numberOfExpiredProducts"] != nil) {
                self.entry.expiredProducts = message["numberOfExpiredProducts"] as! String
                self.defaults.setValue(self.entry.expiredProducts, forKey: "numberOfExpiredProducts")
            } else if(message["numberOfProductsInPantry"] != nil){
                self.entry.productsInPantry = message["numberOfProductsInPantry"] as! String
                self.defaults.setValue(self.entry.productsInPantry, forKey: "numberOfProductsInPantry")
            }
        }
    }
}

struct MyPantryWatchEntry  {
    var productsInPantry : String
    var expiredProducts : String
    var expiringProducts : String
}
