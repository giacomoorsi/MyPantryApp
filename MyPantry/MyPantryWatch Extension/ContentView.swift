//
//  ContentView.swift
//  MyPantryWatch WatchKit Extension
//
//  Created by Giacomo Orsi on 29/05/2021.
//

import SwiftUI

/**
 The view of the Apple Watch app of MyPantry
 */
struct ContentView: View {
    @ObservedObject var model =  MyPantryWatchModel()
    var body: some View {
        ScrollView(){
            VStack(alignment: .center, spacing: 13.0){
                Text("MyPantry")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                VStack(alignment: .center, spacing: 6.0){
                    Text("In dispensa")
                        .font(.title3)
                        .foregroundColor(Color.green)
                    
                    HStack() {
                        Image(systemName: "tray.2").renderingMode(.template)
                            .foregroundColor(.green)
                        Text(String(model.entry.productsInPantry)).foregroundColor(.green)
                    }
                }
                VStack(alignment: .center, spacing: 7.0) {
                    Text("In scadenza").foregroundColor(.orange).font(.title3)
                    HStack() {
                        Image(systemName: "exclamationmark.triangle").renderingMode(.template)
                            .foregroundColor(.orange)
                        Text(String(model.entry.expiringProducts)).foregroundColor(.orange)
                    }
                }
                VStack(alignment: .center, spacing: 7.0) {
                    Text("Scaduti").foregroundColor(.red).font(.title3)
                    HStack() {
                        Image(systemName: "trash").renderingMode(.template)
                            .foregroundColor(.red)
                        Text(String(model.entry.expiredProducts)).foregroundColor(.red)
                    }
                }
            }.frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .center
            )
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
