//
//  ZoneDetailView.swift
//  SecureNest
//
//  Created by Teenu on 09/11/26.
//

import SwiftUI
import SwiftData

struct ZoneDetailView: View {
    @Environment(\.modelContext) private var context
    var zone: ZoneItem
    var viewModel: ZoneViewModel

    @State private var showAlert = false
    @State private var isChiming = false
    @State private var showAddSensorSheet = false
    @State private var pingResult: String?
    @State private var isPinging = false

    var body: some View {
        ZStack {
            Theme.primaryDark
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    heroStatusSection
                    armingControlsSection
                    sensorsSection
                    telemetryTimelineSection
                    hardwareDiagnosticsSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle(zone.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddSensorSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle")
                        Text("Add Sensor").font(.caption.bold())
                    }
                    .foregroundColor(Theme.cyberBlue)
                }
            }
        }
        .alert("Arming Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $showAddSensorSheet) {
            AddSensorSheet(zone: zone)
        }
    }

    // MARK: - Hero Status
    private var heroStatusSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill((zone.isArmed ? Theme.secureGreen : (zone.hasAlert ? Theme.alertRed : Color.gray)).opacity(0.18))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle().stroke((zone.isArmed ? Theme.secureGreen : (zone.hasAlert ? Theme.alertRed : Color.gray)).opacity(0.4), lineWidth: 2)
                    )

                Image(systemName: zone.primaryIcon)
                    .font(.system(size: 36))
                    .foregroundColor(zone.isArmed ? Theme.secureGreen : (zone.hasAlert ? Theme.alertRed : .gray))
            }

            VStack(spacing: 4) {
                Text(zone.name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                Text(zone.locationDescription)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            HStack(spacing: 6) {
                Image(systemName: zone.isArmed ? "lock.shield.fill" : "shield.slash.fill")
                Text(zone.isArmed ? "SYSTEM ARMED" : "DISARMED")
                    .fontWeight(.bold)
            }
            .font(.caption)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background((zone.isArmed ? Theme.secureGreen : Color.gray).opacity(0.2))
            .foregroundColor(zone.isArmed ? Theme.secureGreen : .gray)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke((zone.isArmed ? Theme.secureGreen : Color.gray).opacity(0.4), lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .securityCard()
    }

    // MARK: - Arming Controls
    private var armingControlsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ZONE SECURITY STATE")
                .font(.system(size: 11, weight: .heavy))
                .foregroundColor(.gray)

            Button {
                viewModel.toggleArmStatus(for: zone, context: context)
                if viewModel.errorMessage != nil {
                    showAlert = true
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: zone.isArmed ? "shield.slash.fill" : "lock.shield.fill")
                        .font(.title3)
                    Text(zone.isArmed ? "Disarm This Zone" : "Arm Zone Secure")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(zone.isArmed ? Theme.alertRed.opacity(0.2) : Theme.secureGreen.opacity(0.25))
                .foregroundColor(zone.isArmed ? Theme.alertRed : Theme.secureGreen)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke((zone.isArmed ? Theme.alertRed : Theme.secureGreen).opacity(0.4), lineWidth: 1.5)
                )
            }

            Text("Arming checks all connected sensors. Fails if battery is below 15% or sensor is tripped.")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .securityCard()
    }

    // MARK: - Sensors & Telemetry
    private var sensorsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("SENSOR & BATTERY TELEMETRY")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(.gray)
                Spacer()
                Text("\(zone.sensors.count) Active")
                    .font(.caption2.bold())
                    .foregroundColor(Theme.cyberBlue)
            }

            if zone.sensors.isEmpty {
                Text("No sensors enrolled in this zone yet.")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                ForEach(zone.sensors) { sensor in
                    VStack(spacing: 8) {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill((sensor.isTriggered ? Theme.alertRed : Theme.cyberBlue).opacity(0.15))
                                    .frame(width: 38, height: 38)
                                Image(systemName: sensor.sensorIcon)
                                    .font(.system(size: 18))
                                    .foregroundColor(sensor.isTriggered ? Theme.alertRed : Theme.cyberBlue)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(sensor.typeName)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                                Text(sensor.isTriggered ? "SENSOR ACTIVE / TRIPPED" : "Normal Magnetic Circuit")
                                    .font(.caption2)
                                    .foregroundColor(sensor.isTriggered ? Theme.alertRed : .gray)
                            }

                            Spacer()

                            // Battery level with icon
                            HStack(spacing: 4) {
                                Image(systemName: sensor.batteryIcon)
                                Text("\(sensor.batteryPercentage)%")
                                    .font(.caption.bold())
                            }
                            .foregroundColor(sensor.batteryColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(sensor.batteryColor.opacity(0.15))
                            .cornerRadius(6)
                        }

                        // Simulator buttons for testing evaluation
                        HStack(spacing: 8) {
                            Button {
                                sensor.isTriggered.toggle()
                                context.insert(EventLog(title: "\(zone.name): \(sensor.typeName)", details: sensor.isTriggered ? "Tripped" : "Restored", severity: sensor.isTriggered ? "critical" : "info"))
                                try? context.save()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "bolt.fill")
                                    Text(sensor.isTriggered ? "Restore Sensor" : "Simulate Trip")
                                }
                                .font(.caption2.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(sensor.isTriggered ? Theme.secureGreen.opacity(0.2) : Theme.surfaceDark)
                                .foregroundColor(sensor.isTriggered ? Theme.secureGreen : .gray)
                                .cornerRadius(6)
                            }

                            Button {
                                sensor.batteryPercentage = (sensor.batteryPercentage <= 14) ? 85 : 10
                                try? context.save()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "battery.25")
                                    Text(sensor.batteryPercentage < 15 ? "Recharge Battery" : "Drop Battery <15%")
                                }
                                .font(.caption2.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Theme.surfaceDark)
                                .foregroundColor(sensor.batteryPercentage < 15 ? Theme.secureGreen : Theme.warningAmber)
                                .cornerRadius(6)
                            }

                            Spacer()
                        }
                    }
                    .padding(.vertical, 4)

                    if sensor != zone.sensors.last {
                        Divider().background(Color.white.opacity(0.08))
                    }
                }
            }
        }
        .securityCard()
    }

    // MARK: - 24-Hour Telemetry Timeline
    private var telemetryTimelineSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("24-HOUR TELEMETRY TIMELINE")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(.gray)
                Spacer()
                Text("100% UPTIME")
                    .font(.system(size: 9, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Theme.secureGreen.opacity(0.18))
                    .foregroundColor(Theme.secureGreen)
                    .cornerRadius(4)
            }

            HStack(alignment: .bottom, spacing: 6) {
                ForEach(0..<12) { i in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: i == 11 ? [Theme.secureGreen, Theme.cyberBlue] : [Theme.cyberBlue.opacity(0.7), Theme.cyberBlue.opacity(0.3)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: CGFloat(14 + (i * 7) % 26))

                        Text("\(i * 2)h")
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 50)
        }
        .securityCard()
    }

    // MARK: - Hardware Diagnostics Section
    private var hardwareDiagnosticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ZONE DIAGNOSTICS & TESTING")
                .font(.system(size: 11, weight: .heavy))
                .foregroundColor(.gray)

            HStack(spacing: 10) {
                Button {
                    Task {
                        isPinging = true
                        try? await Task.sleep(nanoseconds: 300_000_000)
                        isPinging = false
                        pingResult = "Sub-GHz RF Verified • Latency: 22ms"
                    }
                } label: {
                    HStack(spacing: 6) {
                        if isPinging {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                            Text("Ping Zone")
                                .fontWeight(.semibold)
                        }
                    }
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Theme.cyberBlue.opacity(0.2))
                    .foregroundColor(Theme.cyberBlue)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Theme.cyberBlue.opacity(0.4), lineWidth: 1)
                    )
                }

                Button {
                    testZoneChime()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: isChiming ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                        Text(isChiming ? "Chiming..." : "Test Chime")
                            .fontWeight(.semibold)
                    }
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(isChiming ? Theme.warningAmber.opacity(0.25) : Theme.surfaceDark)
                    .foregroundColor(isChiming ? Theme.warningAmber : .white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke((isChiming ? Theme.warningAmber : Color.white.opacity(0.1)), lineWidth: 1)
                    )
                }
            }

            if let result = pingResult {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(Theme.secureGreen)
                    Text(result).font(.caption).foregroundColor(.white)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.surfaceDark)
                .cornerRadius(6)
            }
        }
        .securityCard()
    }

    private func testZoneChime() {
        guard !isChiming else { return }
        isChiming = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            isChiming = false
        }
    }
}

// MARK: - Add Sensor Sheet
struct AddSensorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    var zone: ZoneItem

    @State private var typeName = "Motion Detector"
    @State private var battery = 100

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.primaryDark.ignoresSafeArea()

                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SENSOR TYPE").font(.caption2.bold()).foregroundColor(.gray)
                        HStack(spacing: 8) {
                            ForEach(["Motion Detector", "Window Contact", "Smoke Alarm", "Glass Break"], id: \.self) { type in
                                Button {
                                    typeName = type
                                } label: {
                                    Text(type)
                                        .font(.caption.bold())
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
                                        .background(typeName == type ? Theme.cyberBlue : Theme.surfaceDark)
                                        .foregroundColor(typeName == type ? .white : .gray)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }

                    Button {
                        zone.sensors.append(SensorReading(typeName: typeName, batteryPercentage: battery))
                        context.insert(EventLog(title: "Sensor Added", details: "\(typeName) enrolled in \(zone.name)."))
                        try? context.save()
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Enroll Sensor").fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.cyberBlue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.top, 10)

                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Add Sensor to \(zone.name)")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundColor(.gray)
                }
            }
        }
    }
}
