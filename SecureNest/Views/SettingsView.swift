//
//  SettingsView.swift
//  SecureNest
//
//  Created by Teenu on 10/11/26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Binding var isAuthenticated: Bool
    @Query private var zones: [ZoneItem]
    @Query private var logs: [EventLog]

    @AppStorage("pushAlerts") private var pushAlerts = true
    @AppStorage("requirePIN") private var requirePIN = true
    @State private var selectedProfile = "Balanced Home"
    @State private var showResetAlert = false
    @State private var bannerText: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.primaryDark.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        profileCard
                        securityPostureCard
                        preferencesCard
                        dataManagementCard
                        aboutCard
                        signOutButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
            .navigationTitle("System Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .alert("Reset Sample Data?", isPresented: $showResetAlert) {
                Button("Reset Everything", role: .destructive) {
                    try? context.delete(model: ZoneItem.self)
                    try? context.delete(model: SensorReading.self)
                    try? context.delete(model: EventLog.self)
                    MockDataSeeder.seedIfNeeded(context: context)
                    bannerText = "Default zones and telemetry reloaded."
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will restore default sample zones and clear history.")
            }
        }
    }

    // MARK: - Profile Card
    private var profileCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Theme.cyberBlue.opacity(0.2))
                    .frame(width: 54, height: 54)
                Image(systemName: "person.shield.fill")
                    .font(.title2)
                    .foregroundColor(Theme.cyberBlue)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("SecOps Supervisor")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("operator@securenest.internal")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("ADMIN PRIVILEGES")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundColor(Theme.secureGreen)
            }
            Spacer()
        }
        .securityCard()
    }

    // MARK: - Posture Card
    private var securityPostureCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SECURITY POSTURE PROFILE")
                .font(.system(size: 11, weight: .heavy))
                .foregroundColor(.gray)

            HStack(spacing: 8) {
                presetButton(title: "Balanced", icon: "shield.lefthalf.filled", color: Theme.cyberBlue)
                presetButton(title: "Lockdown", icon: "lock.shield.fill", color: Theme.alertRed)
                presetButton(title: "Night Guard", icon: "moon.stars.fill", color: Theme.nightIndigo)
            }

            Text(profileDescription)
                .font(.caption2)
                .foregroundColor(.gray)
                .padding(.top, 2)
        }
        .securityCard()
    }

    private func presetButton(title: String, icon: String, color: Color) -> some View {
        let isSelected = selectedProfile == title
        return Button {
            selectedProfile = title
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(title)
                    .font(.caption2.bold())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? color.opacity(0.25) : Theme.surfaceDark)
            .foregroundColor(isSelected ? color : .gray)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? color : Color.white.opacity(0.1), lineWidth: 1.5)
            )
        }
    }

    private var profileDescription: String {
        switch selectedProfile {
        case "Lockdown":
            return "Zero entry delay. Any tripped perimeter sensor triggers an instant critical siren alert."
        case "Night Guard":
            return "Perimeter contacts and glassbreaks armed; interior motion sensors bypassed."
        default:
            return "Standard 30-second delay for authorized entry; pushes alerts for all alarm events."
        }
    }

    // MARK: - Preferences
    private var preferencesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("NOTIFICATIONS & PREFERENCES")
                .font(.system(size: 11, weight: .heavy))
                .foregroundColor(.gray)

            Toggle("Push Intrusion Notifications", isOn: $pushAlerts)
                .font(.subheadline)
                .foregroundColor(.white)
                .tint(Theme.cyberBlue)

            Toggle("Require Master PIN for Disarming", isOn: $requirePIN)
                .font(.subheadline)
                .foregroundColor(.white)
                .tint(Theme.cyberBlue)
        }
        .securityCard()
    }

    // MARK: - Data Management
    private var dataManagementCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("SWIFTDATA LOCAL PERSISTENCE")
                .font(.system(size: 11, weight: .heavy))
                .foregroundColor(.gray)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Local Database Metrics")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Text("\(zones.count) Zones Persisted • \(logs.count) Events Stored")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "externaldrive.fill.badge.checkmark")
                    .foregroundColor(Theme.secureGreen)
            }

            HStack(spacing: 10) {
                Button {
                    showResetAlert = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset Sample Data")
                    }
                    .font(.caption.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Theme.surfaceDark)
                    .foregroundColor(Theme.warningAmber)
                    .cornerRadius(8)
                }

                Button {
                    try? context.delete(model: EventLog.self)
                    try? context.save()
                    bannerText = "Event log cleared."
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                        Text("Clear Logs")
                    }
                    .font(.caption.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Theme.surfaceDark)
                    .foregroundColor(Theme.alertRed)
                    .cornerRadius(8)
                }
            }

            if let bannerText {
                Text(bannerText)
                    .font(.caption2)
                    .foregroundColor(Theme.secureGreen)
                    .padding(6)
                    .background(Theme.secureGreen.opacity(0.12))
                    .cornerRadius(6)
            }
        }
        .securityCard()
    }

    // MARK: - About Card & Diagnostics
    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ABOUT & DIAGNOSTICS")
                .font(.system(size: 11, weight: .heavy))
                .foregroundColor(.gray)

            HStack {
                Text("Persistence Engine").font(.caption).foregroundColor(.gray)
                Spacer()
                Text("SwiftData (Native)").font(.caption.bold()).foregroundColor(Theme.secureGreen)
            }

            HStack {
                Text("Concurrency Runtime").font(.caption).foregroundColor(.gray)
                Spacer()
                Text("async/await").font(.caption.bold()).foregroundColor(Theme.cyberBlue)
            }

            Divider().background(Color.white.opacity(0.08))

            ShareLink(
                item: generateDiagnosticsReport(),
                subject: Text("SecureNest Gateway Diagnostics"),
                message: Text("Exported system diagnostic report.")
            ) {
                HStack(spacing: 6) {
                    Image(systemName: "doc.text.magnifyingglass")
                    Text("Export System Diagnostics Report")
                        .fontWeight(.semibold)
                }
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Theme.surfaceDark)
                .foregroundColor(Theme.cyberBlue)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Theme.cyberBlue.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .securityCard()
    }

    // MARK: - Sign Out
    private var signOutButton: some View {
        Button(role: .destructive) {
            isAuthenticated = false
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Sign Out of Companion App")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Theme.alertRed.opacity(0.15))
            .foregroundColor(Theme.alertRed)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.alertRed.opacity(0.3), lineWidth: 1)
            )
        }
    }

    private func generateDiagnosticsReport() -> String {
        var report = "=== SECURENEST GATEWAY DIAGNOSTICS ===\n"
        report += "Date: \(Date().formatted(date: .complete, time: .complete))\n"
        report += "Profile: \(selectedProfile)\n"
        report += "Zones Count: \(zones.count)\n"
        report += "Logs Count: \(logs.count)\n\n"
        for z in zones {
            report += " - [\(z.name)]: \(z.isArmed ? "ARMED" : "DISARMED") | Sensors: \(z.sensors.count)\n"
        }
        return report
    }
}
