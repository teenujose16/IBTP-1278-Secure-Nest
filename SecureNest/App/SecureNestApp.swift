//
//  SecureNestApp.swift
//  SecureNest
//
//  Created by Teenu  on 09/11/26.
//

import SwiftUI
import SwiftData

@main
struct SecurityCompanionApp: App {
    @State private var isAuthenticated = false
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: ZoneItem.self, SensorReading.self, EventLog.self)
            MockDataSeeder.seedIfNeeded(context: container.mainContext)
        } catch {
            fatalError("SwiftData initialization failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                TabView {
                    ZoneListView()
                        .tabItem { Label("Zones", systemImage: "shield.checkered") }
                    EventFeedView()
                        .tabItem { Label("Live Feed", systemImage: "bolt.horizontal.fill") }
                    SettingsView(isAuthenticated: $isAuthenticated)
                        .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                }
                .tint(Theme.cyberBlue)
            } else {
                LoginView(isAuthenticated: $isAuthenticated)
            }
        }
        .modelContainer(container)
    }
}
