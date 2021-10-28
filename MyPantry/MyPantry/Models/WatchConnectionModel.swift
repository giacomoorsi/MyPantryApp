//
//  WatchConnectionModel.swift
//  MyPantry
//
//  Created by Giacomo Orsi on 29/05/2021.
//

import Foundation
import WatchConnectivity

/**
 Handles the connection with the Apple Watch app. Everytime there is an update in the number of products in the database, `MyPantryModel` notifies the Apple Watch using the `WatchConnectivityModel`.
 */
class WatchConnectionModel: NSObject, WCSessionDelegate {
    static let model = WatchConnectionModel() // singleton
    
    var session: WCSession
    init(session: WCSession = .default){
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
}
