//
//  WeCanSaveApp.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 24/02/25.
//

import SwiftUI
import SwiftData

@main
struct WeCanSaveApp: App {
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
    
//    var sharedModelContainer: ModelContainer
//
//        init() {
//            let schema = Schema([User.self])
//            sharedModelContainer = try! ModelContainer(for: schema)
//        }
    
    let modelContainer: ModelContainer
        
        init() {
            do {
                modelContainer = try ModelContainer(for: Trip.self)
            } catch {
                fatalError("Could not initialize ModelContainer")
            }
        }

    var body: some Scene {
        WindowGroup {
            TripsListView()
//                .environment(\.modelContext, sharedModelContainer.mainContext)
//                .environmentObject(UserManager(modelContext: sharedModelContainer.mainContext))
        }
        .modelContainer(modelContainer)
    }
}
