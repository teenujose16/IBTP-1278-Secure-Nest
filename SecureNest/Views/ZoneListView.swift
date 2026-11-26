//
//  ZoneListView.swift
//  SecureNest
//
//  Created by Teenu on 09/11/26.
//

import SwiftUI
import SwiftData

struct ZoneListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \ZoneItem.name) private var zones: [ZoneItem]
    @State private var viewModel = ZoneViewModel()
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    @State private var showAddZoneSheet = false
    @State private var showAlert = false

    private var armedCount: Int {
        zones.filter { $0.isArmed }.count
    }

    private var alertCount: Int {
        zones.filter { $0.hasAlert }.count
    }

    private var lowBatteryCount: Int {
        zones.filter { $0.hasLowBattery }.count
    }

    private var filteredZones: [ZoneItem] {
        var result = zones
        switch selectedFilter {
        case "Armed":
            result = result.filter { $0.isArmed }
        case "Disarmed":
            result = result.filter { !$0.isArmed }
        case "Alerts":
            result = result.filter { $0.hasAlert || $0.hasLowBattery }
        default:
            break
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            result = result.filter {
                $0.name.lowercased().contains(query) ||
                $0.locationDescription.lowercased().contains(query)
            }
        }
        return result
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.primaryDark
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 16) {
                        systemStatusBanner
                        quickMetricsRow
                        filterBar
                        searchBar

                        if filteredZones.isEmpty {
                            emptyStateView
                        } else {
                            ForEach(filteredZones) { zone in
                                NavigationLink(value: zone) {
                                    zoneCard(zone)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button {
                                        viewModel.toggleArmStatus(for: zone, context: context)
                                        if viewModel.errorMessage != nil { showAlert = true }
                                    } label: {
                                        Label(zone.isArmed ? "Disarm Zone" : "Arm Zone", systemImage: zone.isArmed ? "shield.slash" : "lock.shield")
                                    }

                                    Divider()

                                    Button(role: .destructive) {
                                        context.delete(zone)
                                        try? context.save()
                                    } label: {
                                        Label("Delete Zone", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
            .navigationTitle("Security Zones")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "shield.checkered")
                            .foregroundColor(Theme.cyberBlue)
                        Text("SecureNest")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddZoneSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Zone")
                                .font(.caption.bold())
                        }
                        .foregroundColor(Theme.cyberBlue)
                    }
                }
            }
            .navigationDestination(for: ZoneItem.self) { zone in
                ZoneDetailView(zone: zone, viewModel: viewModel)
            }
            .alert("Arming Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .sheet(isPresented: $showAddZoneSheet) {
                AddZoneSheet()
            }
        }
    }

    // MARK: - System Status Banner
    private var systemStatusBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill((alertCount > 0 ? Theme.alertRed : (armedCount > 0 ? Theme.secureGreen : Color.gray)).opacity(0.18))
                    .frame(width: 52, height: 52)
                Image(systemName: alertCount > 0 ? "exclamationmark.shield.fill" : (armedCount == 0 ? "shield.slash.fill" : "lock.shield.fill"))
                    .font(.title2)
                    .foregroundColor(alertCount > 0 ? Theme.alertRed : (armedCount > 0 ? Theme.secureGreen : .gray))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(alertCount > 0 ? "ATTENTION REQUIRED" : (armedCount == zones.count && !zones.isEmpty ? "ALL ZONES ARMED" : (armedCount == 0 ? "SYSTEM DISARMED" : "PARTIALLY ARMED")))
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)

                Text("\(armedCount) of \(zones.count) zones armed • \(alertCount) alert(s)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .securityCard()
    }

    // MARK: - Quick Metrics Row
    private var quickMetricsRow: some View {
        HStack(spacing: 8) {
            metricTile(title: "Armed", count: armedCount, color: Theme.secureGreen, icon: "lock.shield.fill")
            metricTile(title: "Disarmed", count: zones.count - armedCount, color: .gray, icon: "shield.slash.fill")
            metricTile(title: "Alerts", count: alertCount, color: Theme.alertRed, icon: "exclamationmark.triangle.fill")
            metricTile(title: "Low Bat", count: lowBatteryCount, color: Theme.warningAmber, icon: "battery.25")
        }
    }

    private func metricTile(title: String, count: Int, color: Color, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 1) {
                Text("\(count)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                Text(title)
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Theme.surfaceDark)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Filter Bar
    private var filterBar: some View {
        HStack(spacing: 8) {
            ForEach(["All", "Armed", "Disarmed", "Alerts"], id: \.self) { filter in
                Button {
                    selectedFilter = filter
                } label: {
                    Text(filter)
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(selectedFilter == filter ? Theme.cyberBlue : Theme.surfaceDark)
                        .foregroundColor(selectedFilter == filter ? .white : .gray)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                }
            }
            Spacer()
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search zones by name or location...", text: $searchText)
                .foregroundColor(.white)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Theme.surfaceDark)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }

    // MARK: - Zone Card Item
    private func zoneCard(_ zone: ZoneItem) -> some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill((zone.isArmed ? Theme.secureGreen : (zone.hasAlert ? Theme.alertRed : Color.gray)).opacity(0.18))
                    .frame(width: 48, height: 48)

                Image(systemName: zone.primaryIcon)
                    .font(.system(size: 22))
                    .foregroundColor(zone.isArmed ? Theme.secureGreen : (zone.hasAlert ? Theme.alertRed : .gray))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(zone.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    if zone.hasAlert {
                        Text("ALERT")
                            .font(.system(size: 9, weight: .heavy))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Theme.alertRed)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }

                Text(zone.locationDescription)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text("\(zone.sensors.count) Sensors")
                        .font(.caption2)
                        .foregroundColor(Theme.cyberBlue)
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text(zone.isArmed ? "ARMED" : "DISARMED")
                        .font(.caption2.bold())
                        .foregroundColor(zone.isArmed ? Theme.secureGreen : .gray)
                }
            }

            Spacer()

            Button {
                viewModel.toggleArmStatus(for: zone, context: context)
                if viewModel.errorMessage != nil { showAlert = true }
            } label: {
                Image(systemName: zone.isArmed ? "lock.fill" : "lock.open.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(zone.isArmed ? .white : Theme.cyberBlue)
                    .frame(width: 38, height: 38)
                    .background(zone.isArmed ? Theme.secureGreen : Theme.surfaceDark)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .securityCard()
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "shield.slash")
                .font(.system(size: 44))
                .foregroundColor(.gray)
            Text("No Zones Found")
                .font(.headline)
                .foregroundColor(.white)
            Text("Try clearing filters or tap '+ Add Zone' to enroll a new security zone.")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .securityCard()
    }
}

// MARK: - Add Zone Sheet
struct AddZoneSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var name = ""
    @State private var locationDescription = ""
    @State private var sensorTypeName = "Door Sensor"
    @State private var batteryPercentage = 100

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.primaryDark.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("ZONE NAME").font(.caption2.bold()).foregroundColor(.gray)
                            TextField("Patio French Doors", text: $name)
                                .padding(12)
                                .background(Theme.surfaceDark)
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("LOCATION DESCRIPTION").font(.caption2.bold()).foregroundColor(.gray)
                            TextField("Ground Floor Rear", text: $locationDescription)
                                .padding(12)
                                .background(Theme.surfaceDark)
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("HARDWARE SENSOR TYPE").font(.caption2.bold()).foregroundColor(.gray)
                            HStack(spacing: 8) {
                                ForEach(["Door Sensor", "PIR Motion", "Smoke Detector", "Laser Grid"], id: \.self) { type in
                                    Button {
                                        sensorTypeName = type
                                    } label: {
                                        Text(type)
                                            .font(.caption.bold())
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 8)
                                            .background(sensorTypeName == type ? Theme.cyberBlue : Theme.surfaceDark)
                                            .foregroundColor(sensorTypeName == type ? .white : .gray)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }

                        Button {
                            guard !name.isEmpty else { return }
                            let newZone = ZoneItem(
                                name: name,
                                locationDescription: locationDescription.isEmpty ? "Perimeter" : locationDescription
                            )
                            newZone.sensors.append(SensorReading(typeName: sensorTypeName, batteryPercentage: batteryPercentage))
                            context.insert(newZone)
                            context.insert(EventLog(title: "Zone Enrolled", details: "\(name) added to monitoring."))
                            try? context.save()
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Enroll Security Zone").fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Theme.cyberBlue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.top, 10)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Enroll New Zone")
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
