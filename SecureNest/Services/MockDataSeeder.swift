//
//  MockDataSeeder.swift
//  SecureNest
//
//  Created by Teenu  on 09/11/26.
//

import Foundation
import SwiftData

struct MockDataSeeder {
    @MainActor
    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<ZoneItem>()
        guard (try? context.fetchCount(descriptor)) == 0 else { return }

        // Zone 1: Ready to arm
        let perimeter = ZoneItem(name: "North Perimeter", locationDescription: "Fences & Main Gate")
        perimeter.sensors.append(SensorReading(typeName: "Laser Grid", batteryPercentage: 90))
        perimeter.sensors.append(SensorReading(typeName: "Gate Sensor", batteryPercentage: 75))

        // Zone 2: Has a low battery sensor (<15%) to trigger the safety block
        let vault = ZoneItem(name: "Data Vault", locationDescription: "Sub-Level B")
        vault.sensors.append(SensorReading(typeName: "PIR Motion", batteryPercentage: 12))
        vault.sensors.append(SensorReading(typeName: "Door Magnet", batteryPercentage: 98))

        // Initial log
        let startupLog = EventLog(title: "System Online", details: "Terminal initialized with default zones.")

        context.insert(perimeter)
        context.insert(vault)
        context.insert(startupLog)
        try? context.save()
    }
}
