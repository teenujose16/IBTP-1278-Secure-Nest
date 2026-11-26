//
//  EventFeedView.swift
//  SecureNest
//
//  Created by Teenu on 10/11/26.
//

import SwiftUI
import SwiftData

struct EventFeedView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \EventLog.timestamp, order: .reverse) private var localLogs: [EventLog]
    @State private var remoteAlerts: [RemoteSecurityAlertDTO] = []
    @State private var isLoading = false
    @State private var pulsingLiveDot = false
    @State private var selectedTab = "All"
    @State private var lastSyncTime: Date?

    private let service = SecurityFeedService()

    private var criticalLogs: [EventLog] {
        localLogs.filter { $0.severity.lowercased() == "critical" || $0.severity.lowercased() == "warning" }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.primaryDark.ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Critical Alert Banner
                        if !criticalLogs.isEmpty {
                            criticalAlertBanner
                        }

                        // Live Telemetry Header Card
                        liveHeaderCard

                        // Filter Chips
                        filterBar

                        if selectedTab == "All" || selectedTab == "Live Cloud" {
                            liveCloudSection
                        }

                        if selectedTab == "All" || selectedTab == "Hardware" {
                            hardwareLogsSection
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
            .navigationTitle("Live Event Feed")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        ShareLink(
                            item: generateAuditReport(),
                            subject: Text("SecureNest Event Log Audit Report"),
                            message: Text("Exported security incident telemetry.")
                        ) {
                            Label("Export Audit Log", systemImage: "square.and.arrow.up")
                        }

                        Divider()

                        Button(role: .destructive) {
                            try? context.delete(model: EventLog.self)
                            try? context.save()
                        } label: {
                            Label("Clear Local Logs", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle").foregroundColor(.gray)
                    }
                }
            }
            .refreshable {
                await loadData()
            }
            .task {
                await loadData()
            }
        }
    }

    // MARK: - Critical Alert Banner
    private var criticalAlertBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.octagon.fill")
                .font(.title2)
                .foregroundColor(Theme.alertRed)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(criticalLogs.count) CRITICAL INCIDENT(S) RECORDED")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundColor(.white)
                Text("Operator review required on zone trip logs.")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(12)
        .background(Theme.alertRed.opacity(0.18))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Theme.alertRed.opacity(0.4), lineWidth: 1.5)
        )
    }

    // MARK: - Live Header Card
    private var liveHeaderCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Theme.secureGreen)
                    .frame(width: 10, height: 10)
                    .scaleEffect(pulsingLiveDot ? 1.4 : 0.9)
                    .opacity(pulsingLiveDot ? 1.0 : 0.6)
                    .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulsingLiveDot)
                    .onAppear { pulsingLiveDot = true }

                Text("LIVE TELEMETRY STREAM")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(Theme.secureGreen)

                Spacer()

                Text("MOCK REST API")
                    .font(.system(size: 9, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Theme.cyberBlue.opacity(0.2))
                    .foregroundColor(Theme.cyberBlue)
                    .cornerRadius(4)
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Gateway: JSONPlaceholder (async/await)")
                        .font(.caption)
                        .foregroundColor(.white)
                    Text(lastSyncTime != nil ? "Last sync: \(lastSyncTime!.formatted(date: .omitted, time: .standard))" : "Pull to refresh")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }

                Spacer()

                Button {
                    Task { await loadData() }
                } label: {
                    HStack(spacing: 4) {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "arrow.clockwise")
                            Text("Fetch Batch")
                        }
                    }
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Theme.cyberBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(isLoading)
            }
        }
        .securityCard()
    }

    // MARK: - Filter Bar
    private var filterBar: some View {
        HStack(spacing: 8) {
            ForEach(["All", "Live Cloud", "Hardware"], id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab)
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(selectedTab == tab ? Theme.cyberBlue : Theme.surfaceDark)
                        .foregroundColor(selectedTab == tab ? .white : .gray)
                        .cornerRadius(16)
                }
            }
            Spacer()
        }
    }

    // MARK: - Live Cloud Section
    private var liveCloudSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("LIVE CLOUD TELEMETRY FEED")
                .font(.system(size: 11, weight: .heavy))
                .foregroundColor(.gray)

            if isLoading && remoteAlerts.isEmpty {
                ProgressView().tint(.white).frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(remoteAlerts.prefix(5)) { alert in
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Theme.cyberBlue.opacity(0.18))
                                .frame(width: 36, height: 36)
                            Image(systemName: "cloud.bolt.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Theme.cyberBlue)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(alert.title.capitalized)
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Text(alert.body)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        }
                        Spacer()
                    }
                    .securityCard()
                }
            }
        }
    }

    // MARK: - Hardware Logs Section
    private var hardwareLogsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("LOCAL HARDWARE INCIDENT LOGS (SWIFTDATA)")
                .font(.system(size: 11, weight: .heavy))
                .foregroundColor(.gray)

            if localLogs.isEmpty {
                Text("No local event logs stored yet.")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                ForEach(localLogs) { log in
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(log.severityColor.opacity(0.18))
                                .frame(width: 36, height: 36)
                            Image(systemName: log.severityIcon)
                                .font(.system(size: 16))
                                .foregroundColor(log.severityColor)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(log.title)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                                Spacer()
                                Text(log.timestamp.formatted(date: .omitted, time: .shortened))
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }

                            Text(log.details)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .securityCard()
                }
            }
        }
    }

    private func loadData() async {
        isLoading = true
        remoteAlerts = (try? await service.fetchRecentAlerts()) ?? []
        lastSyncTime = Date()
        isLoading = false
    }

    private func generateAuditReport() -> String {
        var report = "=== SECURENEST SECURITY INCIDENT AUDIT REPORT ===\n"
        report += "Generated: \(Date().formatted(date: .complete, time: .complete))\n"
        report += "Total Incidents: \(localLogs.count)\n\n"
        for log in localLogs {
            report += "[\(log.timestamp.formatted(date: .abbreviated, time: .standard))] [\(log.severity.uppercased())]\n"
            report += "\(log.title): \(log.details)\n\n"
        }
        return report
    }
}
