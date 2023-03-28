//
//  DecsnowApp.swift
//  Decsnow
//
//  Created by Decsnow on 2023/3/28.
//

import SwiftUI

@main
struct DecsnowApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
