//
//  ZoneLogicTests.swift
//  SecureNest
//
//  Created by Teenu  on 10/11/26.
//

import XCTest
import SwiftData
@testable import SecureNest

@MainActor
final class ZoneLogicTests: XCTestCase {
    var viewModel: ZoneViewModel!
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: ZoneItem.self, SensorReading.self, EventLog.self, configurations: config)
        context = container.mainContext
        viewModel = ZoneViewModel()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        container = nil
        context = nil
    }

    func testArmZone_Success() throws {
        let zone = ZoneItem(name: "Office", locationDescription: "Floor 1")
        zone.sensors.append(SensorReading(typeName: "Door", batteryPercentage: 80))
        context.insert(zone)

        viewModel.toggleArmStatus(for: zone, context: context)

        XCTAssertTrue(zone.isArmed)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testArmZone_FailsOnLowBattery() throws {
        let zone = ZoneItem(name: "Server", locationDescription: "Basement")
        zone.sensors.append(SensorReading(typeName: "Smoke", batteryPercentage: 10)) // < 15%
        context.insert(zone)

        viewModel.toggleArmStatus(for: zone, context: context)

        XCTAssertFalse(zone.isArmed)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testArmZone_FailsWhenTripped() throws {
        let zone = ZoneItem(name: "Gate", locationDescription: "Yard")
        zone.sensors.append(SensorReading(typeName: "Laser", batteryPercentage: 90, isTriggered: true))
        context.insert(zone)

        viewModel.toggleArmStatus(for: zone, context: context)

        XCTAssertFalse(zone.isArmed)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testDisarmZone_AlwaysSucceeds() throws {
        let zone = ZoneItem(name: "Lobby", locationDescription: "Entrance", isArmed: true)
        context.insert(zone)

        viewModel.toggleArmStatus(for: zone, context: context)

        XCTAssertFalse(zone.isArmed)
        XCTAssertNil(viewModel.errorMessage)
    }
}
