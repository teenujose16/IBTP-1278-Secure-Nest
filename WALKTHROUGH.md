# Walkthrough: SecureNest Feature Guide

This walkthrough guides you through each feature of the **SecureNest: Security Monitoring Companion** app, demonstrating how all 6 project requirements are met.

---

## 1. Mock Login Authentication

```
+------------------------------------------+
|            [Shield Icon]                 |
|             SecureNest                   |
|  Security Monitoring Companion           |
|                                          |
|  OPERATOR SECURITY PIN                   |
|  [ •••• [Eye Icon]                     ] |
|                                          |
|  [     Authorize Terminal Gateway      ] |
|                                          |
|  * Auto-fill Default PIN (4829)          |
|                                          |
|  GATEWAY ONLINE • AES-256 • SWIFTDATA    |
+------------------------------------------+
```

- **Features**:
  - Secure PIN entry with show/hide password toggle.
  - Quick-fill shortcut for evaluators: **"Auto-fill Default PIN (4829)"**.
  - Live cybersecurity terminal footer indicating Gateway status and encryption.
  - State-bound session toggle (`isAuthenticated`).

---

## 2. Monitored Security Zones List

```
+------------------------------------------+
|  = SecureNest                [+ Add Zone]|
|  [Status Banner: ALL ZONES ARMED]        |
|  [Metrics: 2 Armed | 0 Disarmed | 0 Alerts|
|  [Filter Chips: All | Armed | Disarmed ] |
|  [Search: Search zones by name...      ] |
|                                          |
|  [Icon] North Perimeter                  |
|         Fences & Main Gate • ARMED       |
|         [2 Sensors]           [Lock Btn] |
+------------------------------------------+
```

- **Features**:
  - **System Status Header**: Real-time arming banner and active alert counts.
  - **4-Pillar KPI Metrics Dashboard**: Quick glance tiles for Armed, Disarmed, Alerts, and Low Battery.
  - **Filter Chips & Live Search**: Instant queries by zone name or location.
  - **Zone Enrollment Sheet (`AddZoneSheet`)**: Tap `+ Add Zone` in the toolbar to enroll custom zones with name, location, and hardware sensor type directly into SwiftData!
  - **Context Menu Actions**: Long-press any zone card to Arm/Disarm or Delete.

---

## 3. Zone Detail & Hardware Sensor Telemetry

```
+------------------------------------------+
|  < Security Zones    North Perimeter     |
|                                          |
|          [Large Sensor Icon Badge]       |
|          North Perimeter                 |
|          Fences & Main Gate              |
|          [SYSTEM ARMED BADGE]            |
|                                          |
|  ZONE SECURITY STATE                     |
|  [        Disarm This Zone             ] |
|                                          |
|  SENSOR & BATTERY TELEMETRY (2 Active)   |
|  - Laser Grid                            |
|    Normal Magnetic Circuit • 90% Battery |
|    [Simulate Trip]  [Drop Battery <15%]  |
|                                          |
|  24-HOUR TELEMETRY TIMELINE              |
|  [||||||||||||] 100% Uptime              |
|                                          |
|  ZONE DIAGNOSTICS & TESTING              |
|  [ Ping Zone ]    [ Test Chime ]         |
+------------------------------------------+
```

- **Features**:
  - **Hero Status Card**: 80×80 double-ringed sensor badge with status capsule.
  - **Arming Safety Validation**: Blocks arming if a sensor's battery drops under 15% or if a sensor is tripped.
  - **Live Evaluation Simulators**:
    - Tap **Simulate Trip** to trip/restore sensors and test arming rejection!
    - Tap **Drop Battery <15%** to test the low-battery arming blocker!
  - **24-Hour Telemetry Timeline**: Hourly gradient bar graph of sensor heartbeats.
  - **Interactive Chime Test**: Emits simulated 85dB chime tone with audio wave animation.
  - **Add Sensor Sheet**: Tap `+ Add Sensor` in the toolbar to enroll additional sensors into this zone.

---

## 4. Live-Style Event Feed (Free Mock API via `async/await`)

```
+------------------------------------------+
|  Live Event Feed           [Audit Menu]  |
|                                          |
|  [CRITICAL ALERTS BANNER (If Active)]    |
|                                          |
|  [LIVE TELEMETRY STREAM]                 |
|  Gateway: JSONPlaceholder (async/await)  |
|  [ Fetch Batch ]                         |
|                                          |
|  LIVE CLOUD TELEMETRY FEED               |
|  - Cloud Alert DTO from JSONPlaceholder  |
|                                          |
|  LOCAL HARDWARE INCIDENT LOGS (SWIFTDATA)|
|  - Zone Armed / Disarmed Logs            |
|  - Sensor Trip / Restore Audit Logs      |
+------------------------------------------+
```

- **Features**:
  - Fetches live events from the free public REST API (`https://jsonplaceholder.typicode.com/posts?_limit=10`) using `URLSession` and `async/await`.
  - Pull-to-refresh support (`.refreshable`).
  - Glowing Critical Alerts Banner for tripped zones.
  - Local hardware audit logs persisted in SwiftData.
  - Native **`ShareLink`** to export a formatted Security Incident Audit Report.

---

## 5. System Settings & Posture Profiles

```
+------------------------------------------+
|  System Settings                         |
|                                          |
|  [User Badge] SecOps Supervisor (Admin)  |
|                                          |
|  SECURITY POSTURE PROFILE                |
|  [ Balanced ]  [ Lockdown ]  [Night Guard|
|                                          |
|  NOTIFICATIONS & PREFERENCES             |
|  Push Intrusion Notifications: [ ON ]    |
|  Require Master PIN for Disarming: [ ON ]|
|                                          |
|  SWIFTDATA LOCAL PERSISTENCE             |
|  2 Zones Persisted • 4 Events Stored     |
|  [ Reset Sample Data ]  [ Clear Logs ]   |
|                                          |
|  [ Export System Diagnostics Report ]    |
|  [ Sign Out of Companion App ]           |
+------------------------------------------+
```

- **Features**:
  - Security Posture Presets (`Balanced`, `Lockdown`, `Night Guard`).
  - SwiftData metrics displaying persisted zones and event count.
  - Actions to reset sample data or clear logs.
  - Native **`ShareLink`** to export a comprehensive System Diagnostics Report.
  - Sign-out button.

---

## 6. Automated Unit Testing (XCTest)

### How to Run the Tests
1. In Xcode, select the test target `SecureNestTests`.
2. Press <kbd>Cmd</kbd> + <kbd>U</kbd> or choose **Product > Test**.
3. View results in the **Test Navigator** (<kbd>Cmd</kbd> + <kbd>6</kbd>).

### Test Coverage in `ZoneLogicTests.swift`
- **`testArmZone_Success`**: Validates arming when all sensors are healthy.
- **`testArmZone_FailsOnLowBattery`**: Validates arming rejection when battery < 15%.
- **`testArmZone_FailsWhenTripped`**: Validates arming rejection when sensor is open/tripped.
- **`testDisarmZone_AlwaysSucceeds`**: Validates proper transition back to disarmed state.
