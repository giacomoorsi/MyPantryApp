//
//  MyPantryWidget.swift
//  MyPantryWidget
//
//  Created by Giacomo Orsi on 27/05/2021.
//

import WidgetKit
import SwiftUI
import Intents
import Foundation
import UIKit
import CoreData

struct Provider : TimelineProvider {
    func placeholder(in context: Context) -> MyPantryWidgetEntry {
        let entry = MyPantryWidgetEntry(date: Date(), productsInPantry: "48", expiredProducts: "2", expiringProducts: "14")
        
        return entry
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MyPantryWidgetEntry) -> Void) {
        let entry = MyPantryWidgetEntry(date: Date(), productsInPantry: "48", expiredProducts: "2", expiringProducts: "14")
        
        completion(entry)
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<MyPantryWidgetEntry>) -> Void) {
        
        let defaults: UserDefaults = UserDefaults(suiteName: "group.giacomoorsi.MyPantry")!
        
        //defaults.setObject(<YourArray, forKey:<KeyName>)
        let numberOfProductsInPantry = defaults.string(forKey: "numberOfProductsInPantry")!
        let numberOfExpiringProducts = defaults.string(forKey: "numberOfExpiringProducts")!
        let numberOfExpiredProducts = defaults.string(forKey: "numberOfExpiredProducts")!
        
        
        let entry = MyPantryWidgetEntry(date: Date(), productsInPantry: numberOfProductsInPantry, expiredProducts: numberOfExpiredProducts, expiringProducts: numberOfExpiringProducts)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
    
}

/**
 An entry on the Widget
 */
struct MyPantryWidgetEntry : TimelineEntry {
    let date : Date
    let productsInPantry : String
    let expiredProducts : String
    let expiringProducts : String
}

/**
 The view of the Widget
 */
struct MyPantryWidgetEntryView : View {
    var entry : Provider.Entry
    
    var body : some View {
        VStack{
            Text("MyPantry")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20.0) {
                VStack(alignment: .leading, spacing: 10){
                    Text("In dispensa")
                        .foregroundColor(Color.green)
                    HStack() {
                        Image(systemName: "tray.2").renderingMode(.template)
                            .foregroundColor(.green)
                        Text(String(entry.productsInPantry)).foregroundColor(.green)
                    }
                }
                VStack(alignment: .leading, spacing: 7.0) {
                    Text("In scadenza").foregroundColor(.orange)
                    HStack() {
                        Image(systemName: "exclamationmark.triangle").renderingMode(.template)
                            .foregroundColor(.orange)
                        Text(String(entry.expiringProducts)).foregroundColor(.orange)
                    }
                }
                VStack(alignment: .leading, spacing: 7.0) {
                    Text("Scaduti").foregroundColor(.red)
                    HStack() {
                        Image(systemName: "trash").renderingMode(.template)
                            .foregroundColor(.red)
                        Text(String(entry.expiredProducts)).foregroundColor(.red)
                    }
                }
            }
            .padding()
        }
    }
}
/**
 The Widget for MyPantry
 */
@main
struct MyPantryWidget: Widget {
    let kind: String = "MyPantryWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) {
            entry in MyPantryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("MyPantry")
        .description("Mostra un riepilogo della tua dispensa")
        .supportedFamilies([.systemMedium])
    }
}

/**
 The preview for the Widget
 */
struct MyPantryWidget_Previews: PreviewProvider {
    static var previews: some View {
        MyPantryWidgetEntryView(entry: Provider.Entry(date: Date(), productsInPantry: "48", expiredProducts: "2", expiringProducts: "14"))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}



