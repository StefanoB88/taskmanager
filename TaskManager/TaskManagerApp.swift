//
//  TaskManagerApp.swift
//  TaskManager
//
//  Created by Stefano on 11.03.25.
//

import SwiftUI

@main
struct TaskManagerApp: App {
    let persistenceController = PersistentController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.context)
        }
    }
}
