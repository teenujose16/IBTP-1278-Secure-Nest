//
//  ZoneViewModel.swift
//  SecureNest
//
//  Created by Teenu  on 09/11/26.
//

import Foundation
import SwiftData
import Observation

enum SecurityArmError: LocalizedError {
    case lowBattery(String)
    case sensorTripped(String)

    var errorDescription: String? {
        switch self {
        case .lowBattery(let name):
            return "Cannot arm: '\(name)' battery is below 15%."
        case .sensorTripped(let name):
            return "Cannot arm: '\(name)' is reporting an active trigger."
        }
    }
}

@Observable
final class ZoneViewModel {
    var errorMessage: String?

    func validateCanArm(zone: ZoneItem) throws {
        for sensor in zone.sensors {
            if sensor.batteryPercentage < 15 {
                throw SecurityArmError.lowBattery(sensor.typeName)
            }
            if sensor.isTriggered {
                throw SecurityArmError.sensorTripped(sensor.typeName)
            }
        }
    }

    func toggleArmStatus(for zone: ZoneItem, context: ModelContext) {
        errorMessage = nil
        if !zone.isArmed {
            do {
                try validateCanArm(zone: zone)
                zone.isArmed = true
                zone.lastArmChangedAt = Date()
                context.insert(EventLog(title: "\(zone.name) Armed", details: "Zone secured successfully."))
            } catch {
                self.errorMessage = error.localizedDescription
            }
        } else {
            zone.isArmed = false
            zone.lastArmChangedAt = Date()
            context.insert(EventLog(title: "\(zone.name) Disarmed", details: "Disarmed by user.", severity: "warning"))
        }
        try? context.save()
    }
}
