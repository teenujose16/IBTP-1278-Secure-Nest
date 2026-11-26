# SecureNest: Security Monitoring Companion App

A modern, production-grade **Security Monitoring Companion** application built with **SwiftUI**, **SwiftData**, and **Swift Concurrency (`async/await`)**.

---

## 1. Project Description

**SecureNest** is a native multi-platform security monitoring application designed for iOS, iPadOS, and macOS. Acting as an operator command console, the app delivers real-time situational awareness across monitored perimeter security zones, enforces hardware arming safety rules, streams live cloud telemetry over modern asynchronous pipelines, and maintains an offline-first persistent store.

### Core Highlights
- **Hardware Arming Safety Rules**: Evaluates battery levels ($<15\%$) and contact integrity in real time, preventing compromised zones from arming.
- **Native Offline Persistence**: Uses **SwiftData** to ensure all zone statuses, sensor readings, and incident logs remain accessible and manageable without an internet connection.
- **Dual-Stream Telemetry**: Decouples remote live REST feeds (`async/await`) from local SwiftData hardware audit logs, with instant severity filtering.
- **Security Posture Profiles**: Switchable operational presets (`Balanced Home`, `Lockdown`, and `Night Guard`) adapt trip sensitivity and entry delays.

---

## 2. Requirements Compliance Matrix

| Requirement | Description | Status | Implementation Details in This Repo |
| :--- | :--- | :---: | :--- |
| **1. Multi-screen NavigationStack** | Mock Login, Zone List (armed/disarmed status with icons), Zone Detail (sensor/battery readings) | **Complete** | Type-safe `NavigationStack` with `LoginView` (password reveal toggle + status footer), `ZoneListView` (KPI metrics, Add Zone sheet, context menus), and `ZoneDetailView` (telemetry readings, 24h timeline, chime test). |
| **2. Live Event Feed** | Live-style event feed consuming a free mock API via `async/await` | **Complete** | `SecurityFeedService` consuming `https://jsonplaceholder.typicode.com/posts?_limit=10` with `URLSession`, `async/await`, animated pulsing live dot, sticky critical breach alert banner, and audit report export. |
| **3. Settings Screen** | Dedicated settings and preferences interface | **Complete** | `SettingsView` with security posture presets (`Balanced`, `Lockdown`, `Night Guard`), Master PIN toggle, storage metrics, sample data reset, and system diagnostics report export (`ShareLink`). |
| **4. Local Persistence** | SwiftData or Core Data (native, free) | **Complete** | Native **SwiftData** schema (`ZoneItem`, `SensorReading`, `EventLog`) with cascading relationships (`@Relationship(deleteRule: .cascade)`), live `@Query` reactivity, and full CRUD enrollment. |
| **5. XCTest Suite** | Unit tests covering the arm/disarm business logic | **Complete** | `SecureNestTests/ZoneLogicTests.swift` testing arming success, low battery prevention ($<15\%$), tripped sensor prevention, and disarming. |
| **6. Submission Deliverables** | Repository + Architecture Note + Walkthrough | **Complete** | Fully documented in `README.md`, `ARCHITECTURE.md`, `WALKTHROUGH.md`, and `DEMO_SCRIPT.md`. |

---

## 3. Technology Stack & Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│        SwiftUI 5.0 • NavigationStack • Custom Theme         │
├──────────────────────────────┬──────────────────────────────┤
│      State Management        │         Domain Logic         │
│  @Observable ViewModels      │  Arming Safety Validators    │
│  SwiftData @Query Wrappers   │  Security Posture Presets    │
├──────────────────────────────┼──────────────────────────────┤
│       Networking Layer       │      Persistence Layer       │
│  URLSession • async/await    │  Native SwiftData (@Model)   │
│  Structured Concurrency      │  Relational Relational Graph │
└──────────────────────────────┴──────────────────────────────┘
```

- **Language**: Swift 5.10 / Swift 6
- **UI Framework**: SwiftUI (Declarative, reactive, responsive across iOS and macOS)
- **Persistence Engine**: Apple **SwiftData** (`@Model`, `ModelContainer`, `ModelContext`)
- **Networking**: Foundation `URLSession` with structured Swift Concurrency (`Task`, `async/await`, `.refreshable`)
- **Architecture Pattern**: Layered **MVVM** + **Service / Repository Pattern**
- **Test Framework**: Apple **XCTest** (In-Memory hermetic test runner)

---

## 4. Key Features & Screens

1. **Cybersecurity Terminal Login ([LoginView.swift](file:///Users/teenu/Desktop/SecureNest/SecureNest/Views/LoginView.swift))**:
   - Ambient background glow spheres & gradient hero shield badge.
   - Show / hide password visibility toggle (`eye.fill` / `eye.slash.fill`).
   - Live terminal security footer (`GATEWAY ONLINE • AES-256 • SWIFTDATA PERSISTED`).
   - Reviewer demo autofill shortcut button (`PIN: 4829`).

2. **Zone List & Hardware Sensor Enrollment ([ZoneListView.swift](file:///Users/teenu/Desktop/SecureNest/SecureNest/Views/ZoneListView.swift))**:
   - System Status Header banner with dynamic status (`ALL ZONES ARMED`, `ATTENTION REQUIRED`, `SYSTEM DISARMED`).
   - Real-time 4-pillar KPI metrics dashboard (Armed, Disarmed, Alerts, Low Bat).
   - Filter chips (`All`, `Armed`, `Disarmed`, `Alerts`) and live search bar.
   - Modal Sensor Enrollment Sheet (`AddZoneSheet`): Add custom security zones directly into SwiftData.
   - Zone card context menus for instant arm/disarm and deletion.

3. **Zone Detail & Hardware Diagnostics ([ZoneDetailView.swift](file:///Users/teenu/Desktop/SecureNest/SecureNest/Views/ZoneDetailView.swift))**:
   - 80×80 double-ringed sensor badge with status capsule.
   - Arming controls with safety alert validation (blocks arming if any sensor battery is $<15\%$ or tripped).
   - Sensor telemetry rows with battery icon gauges (`CR123A` cell monitoring).
   - Interactive evaluator simulator buttons (`Simulate Trip` and `Drop Battery <15%`) to test arming safety rules live!
   - 24-Hour Telemetry Timeline with hourly gradient activity bars.
   - Interactive Zone Chime & Siren Test (simulated 85dB tone with audio wave animation).
   - Add Sensor Sheet (`AddSensorSheet`) to enroll additional sensors to any zone.

4. **Live Incident Feed & Audit Export ([EventFeedView.swift](file:///Users/teenu/Desktop/SecureNest/SecureNest/Views/EventFeedView.swift))**:
   - Consumes live alerts from `https://jsonplaceholder.typicode.com/posts?_limit=10` via `URLSession` and `async/await`.
   - Animated pulsing live status dot indicating active cloud connection.
   - Sticky glowing Critical Incident Alert banner for active breaches.
   - Local SwiftData hardware logs with severity badges.
   - Native `ShareLink` for exporting formatted Security Incident Audit Reports (`.txt`).

5. **Security Posture & Diagnostics ([SettingsView.swift](file:///Users/teenu/Desktop/SecureNest/SecureNest/Views/SettingsView.swift))**:
   - SecOps Supervisor Profile Card with admin status.
   - Security Posture Presets: `Balanced Home`, `Lockdown`, and `Night Guard`.
   - Push notifications and Master PIN toggle controls.
   - SwiftData local persistence metrics, sample data reload, and log purging.
   - Native `ShareLink` for exporting Gateway Diagnostics Reports (`.txt`).

---

## 5. Quick Start Guide

### Prerequisites
- macOS 14.0 (Sonoma) or macOS 15.0+ (Sequoia)
- Xcode 15.4 or Xcode 16.0+
- iOS 17.0+ / macOS 14.0+ deployment target

### Running in Xcode
1. Open `SecureNest.xcodeproj` in Xcode.
2. Select your run destination:
   - Any iOS Simulator (e.g. **iPhone 15 Pro** / **iPhone 16 Pro**)
   - Or **My Mac (Mac Catalyst / Designed for iPad / Native macOS)**.
3. Clean the build folder: <kbd>Shift</kbd> + <kbd>Cmd</kbd> + <kbd>K</kbd>.
4. Build and Run: <kbd>Cmd</kbd> + <kbd>R</kbd>.
5. Run the Unit Test suite: <kbd>Cmd</kbd> + <kbd>U</kbd>.

---

## 6. Project Documentation Links
- **[Architecture Note (ARCHITECTURE.md)](file:///Users/teenu/Desktop/SecureNest/ARCHITECTURE.md)**: Exhaustive technical architecture, MVVM design, Mermaid sequence and ER diagrams, arming safety truth table, and data modeling.
- **[Feature Walkthrough (WALKTHROUGH.md)](file:///Users/teenu/Desktop/SecureNest/WALKTHROUGH.md)**: End-to-end user manual, screen-by-screen guide with ASCII diagrams, simulator test instructions, and verification steps.
- **[Demo Video Presentation Script (DEMO_SCRIPT.md)](file:///Users/teenu/Desktop/SecureNest/DEMO_SCRIPT.md)**: 3-minute video recording script with scene-by-scene talking points and simulator cues.
