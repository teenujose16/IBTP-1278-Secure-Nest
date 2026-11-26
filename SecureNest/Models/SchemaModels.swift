//
//  SchemaModels.swift
//  SecureNest
//
//  Created by Teenu  on 09/11/26.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class ZoneItem: Identifiable, Hashable {
    @Attribute(.unique) var id: UUID
    var name: String
    var locationDescription: String
    var isArmed: Bool
    var lastArmChangedAt: Date
    @Relationship(deleteRule: .cascade) var sensors: [SensorReading]
    
    init(name: String, locationDescription: String, isArmed: Bool = false) {
        self.id = UUID()
        self.name = name
        self.locationDescription = locationDescription
        self.isArmed = isArmed
        self.lastArmChangedAt = Date()
        self.sensors = []
    }

    static func == (lhs: ZoneItem, rhs: ZoneItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var hasAlert: Bool {
        sensors.contains { $0.isTriggered }
    }
    
    var hasLowBattery: Bool {
        sensors.contains { $0.batteryPercentage < 15 }
    }

    var primaryIcon: String {
        guard let first = sensors.first?.typeName.lowercased() else { return "shield.checkered" }
        if first.contains("door") || first.contains("gate") { return "door.left.hand.open" }
        if first.contains("motion") || first.contains("pir") { return "sensor.motion" }
        if first.contains("smoke") || first.contains("fire") { return "flame.circle.fill" }
        if first.contains("laser") { return "waveform.path.badge.exclamationmark" }
        if first.contains("glass") { return "shield.lefthalf.filled" }
        return "shield.checkered"
    }
}

@Model
final class SensorReading: Identifiable, Hashable {
    @Attribute(.unique) var id: UUID
    var typeName: String
    var batteryPercentage: Int
    var isTriggered: Bool
    var lastCheckin: Date
    
    init(typeName: String, batteryPercentage: Int, isTriggered: Bool = false) {
        self.id = UUID()
        self.typeName = typeName
        self.batteryPercentage = batteryPercentage
        self.isTriggered = isTriggered
        self.lastCheckin = Date()
    }

    static func == (lhs: SensorReading, rhs: SensorReading) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var sensorIcon: String {
        let name = typeName.lowercased()
        if name.contains("door") || name.contains("gate") { return "door.left.hand.closed" }
        if name.contains("motion") || name.contains("pir") { return "sensor.motion" }
        if name.contains("smoke") || name.contains("fire") { return "flame.circle.fill" }
        if name.contains("laser") { return "waveform.path.badge.exclamationmark" }
        return "sensor.fill"
    }

    var batteryIcon: String {
        switch batteryPercentage {
        case 80...100: return "battery.100"
        case 55..<80: return "battery.75"
        case 25..<55: return "battery.50"
        case 1..<25: return "battery.25"
        default: return "battery.0"
        }
    }

    var batteryColor: Color {
        if batteryPercentage > 50 { return Theme.secureGreen }
        if batteryPercentage >= 15 { return Theme.warningAmber }
        return Theme.alertRed
    }
}

@Model
final class EventLog: Identifiable, Hashable {
    @Attribute(.unique) var id: UUID
    var title: String
    var details: String
    var timestamp: Date
    var severity: String
    
    init(title: String, details: String, severity: String = "info") {
        self.id = UUID()
        self.title = title
        self.details = details
        self.timestamp = Date()
        self.severity = severity
    }

    static func == (lhs: EventLog, rhs: EventLog) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var severityColor: Color {
        switch severity.lowercased() {
        case "critical", "alert", "error": return Theme.alertRed
        case "warning": return Theme.warningAmber
        default: return Theme.cyberBlue
        }
    }

    var severityIcon: String {
        switch severity.lowercased() {
        case "critical", "alert", "error": return "exclamationmark.octagon.fill"
        case "warning": return "exclamationmark.triangle.fill"
        default: return "info.circle.fill"
        }
    }
}
