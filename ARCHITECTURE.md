# Architecture Note: SecureNest Companion App

**Document Version**: 2.0  
**Target Platform**: iOS 17.0+ / macOS 14.0+  
**Architecture Pattern**: Layered MVVM + Repository/Service Pattern + Native SwiftData  
**Persistence Engine**: Apple SwiftData (Native, Zero Third-Party Dependencies)  
**Concurrency Engine**: Modern Swift Concurrency (`async/await`, Structured Tasks, `@MainActor`)  

---

## 1. Executive Summary & Architectural Intent

**SecureNest** is a native companion application designed for physical security monitoring, zone surveillance, and hardware telemetry telemetry ingestion. The system provides real-time situational awareness across monitored perimeter zones, enforces strict hardware arming safety rules, streams remote cloud telemetry over modern asynchronous pipelines, and maintains an offline-first persistent store.

### Core Architectural Goals
1. **Safety-Critical Business Invariants**: Arming logic must prevent arming compromised zones (e.g., active intrusions or critically depleted sensor batteries).
2. **Offline-First Resilience**: All zones, sensor telemetry, and incident audit logs are persisted locally using native **SwiftData**, guaranteeing complete functional autonomy without network connectivity.
3. **Asynchronous Telemetry Ingestion**: Remote live feeds consume REST APIs using modern Swift Concurrency (`async/await`) decoupled from the UI thread.
4. **Declarative Unidirectional Data Flow**: Seamless state synchronization from SwiftData models to SwiftUI views via `@Observable` view models and `@Query` property wrappers.
5. **Multiplatform Parity**: Complete cross-platform execution on iOS, iPadOS, and macOS with platform-adaptive controls.

---

## 2. High-Level System Architecture

The application is structured into four distinct layers following the **Model-View-ViewModel (MVVM)** and **Service / Repository** architectural patterns:

```mermaid
flowchart TD
    subgraph Presentation ["1. Presentation Layer (SwiftUI + NavigationStack)"]
        LV["LoginView\n(Mock Gateway Auth & PIN)"]
        ZLV["ZoneListView\n(KPI Dashboard, Search & Filter)"]
        AZS["AddZoneSheet\n(Hardware Enrollment)"]
        ZDV["ZoneDetailView\n(Telemetry, 24h Timeline & Chime)"]
        ASS["AddSensorSheet\n(Sensor Provisioning)"]
        EFV["EventFeedView\n(Live Cloud Stream & Incident Logs)"]
        SV["SettingsView\n(Posture Presets & Diagnostics)"]
    end

    subgraph StateLogic ["2. ViewModel & State Management Layer"]
        ZVM["ZoneViewModel\n(@Observable, @MainActor)"]
        AUTH["Session State\n(@State isAuthenticated)"]
        PREF["AppStorage Preferences\n(pushAlerts, requirePIN)"]
    end

    subgraph DomainService ["3. Domain & Service Layer"]
        VR["Arming Safety Validator\n(Battery < 15% / Tripped Check)"]
        SFS["SecurityFeedService\n(URLSession async/await REST Client)"]
        MDS["MockDataSeeder\n(Deterministic Initial Fixtures)"]
    end

    subgraph PersistenceNetwork ["4. Data & Persistence Layer"]
        MC["SwiftData ModelContext\n(In-Memory / SQLite Persistent Container)"]
        ZI[("ZoneItem (@Model)")]
        SR[("SensorReading (@Model)")]
        EL[("EventLog (@Model)")]
        REST["Remote Free Mock API\n(JSONPlaceholder REST Endpoints)"]
    end

    %% Presentation to State
    LV --> AUTH
    ZLV --> ZVM
    ZLV --> AZS
    ZDV --> ZVM
    ZDV --> ASS
    EFV --> SFS
    SV --> PREF

    %% State to Domain/Persistence
    ZVM --> VR
    VR --> MC
    AZS --> MC
    ASS --> MC
    EFV --> MC
    SV --> MC
    MDS --> MC
    SFS --> REST

    %% Persistence Relationships
    MC --> ZI
    MC --> SR
    MC --> EL
    ZI -- "1-to-Many (Cascade)" --> SR
```

---

## 3. Data Schema & Entity Relationship Architecture

Persistence is powered by Apple's native **SwiftData** framework, operating on a unified relational object graph:

```mermaid
erDiagram
    ZoneItem ||--o{ SensorReading : "cascades (1:N)"
    ZoneItem {
        UUID id PK "Unique hardware identifier"
        String name "Friendly zone label"
        String locationDescription "Physical placement description"
        Boolean isArmed "Current armed/disarmed state"
        Date lastArmChangedAt "Timestamp of last mode shift"
    }
    SensorReading {
        UUID id PK "Unique sensor identifier"
        String typeName "Door, Motion, Smoke, Laser, Glass"
        Int batteryPercentage "Cell charge 0-100%"
        Boolean isTriggered "Active trip / open contact state"
        Date lastCheckin "Hardware heartbeat timestamp"
    }
    EventLog {
        UUID id PK "Unique event log identifier"
        String title "Incident headline"
        String details "Explanatory context & source"
        Date timestamp "Event occurrence time"
        String severity "info / warning / critical"
    }
```

### Key Schema Characteristics
- **Cascade Deletion**: When a `ZoneItem` is deleted, its child `SensorReading` entities are automatically purged via `@Relationship(deleteRule: .cascade)` to maintain relational integrity.
- **Explicit Identifiable & Hashable Conformance**: Implements deterministic `==` and `hash(into:)` based on `id: UUID`, ensuring flawless SwiftUI collection diffing and navigation routing.
- **Computed Telemetry Properties**: Domain models encapsulate computed UI helpers (`primaryIcon`, `batteryIcon`, `batteryColor`, `hasAlert`, `hasLowBattery`) keeping views declarative and logic-free.

---

## 4. State Management & Unidirectional Data Flow

The application enforces a unidirectional data flow (UDF) pipeline:

```mermaid
sequenceDiagram
    autonumber
    actor Operator as Security Operator
    participant View as ZoneDetailView
    participant VM as ZoneViewModel
    participant Validator as Arming Safety Rules
    participant DB as SwiftData ModelContext
    participant Query as ZoneListView (@Query)

    Operator->>View: Tap "Arm Zone Secure"
    View->>VM: toggleArmStatus(for: zone, context)
    VM->>Validator: validateCanArm(zone)
    
    alt Sensor Tripped or Battery < 15%
        Validator-->>VM: throw SecurityArmError (lowBattery / sensorTripped)
        VM-->>View: Publish errorMessage & trigger alert
        View-->>Operator: Display "Arming Error" modal (State remains Disarmed)
    else All Sensors Clear & Healthy
        Validator-->>VM: Validation Passed
        VM->>DB: zone.isArmed = true
        VM->>DB: context.insert(EventLog "Zone Armed")
        VM->>DB: try context.save()
        DB-->>Query: ModelContext change notification
        Query-->>Operator: Live re-render UI with Green "ARMED" badge
    end
```

### State Lifecycle Layers
1. **Ephemeral View State (`@State`, `@FocusState`)**: Manages view-local concerns such as sheet presentation, password visibility, search filters, and audio chime timers.
2. **Observable Business Logic (`@Observable ZoneViewModel`)**: Handles arm/disarm command dispatching, safety validation, and transient error signaling without Combine overhead.
3. **Persistent Global Graph (`@Query`, `@Environment(\.modelContext)`)**: Automatically synchronizes views with the underlying SQLite store whenever changes commit.
4. **App Session State (`@AppStorage`, `@Binding`)**: Tracks persistent user preferences (push notification settings, master PIN requirements) and authentication tokens across app launches.

---

## 5. Domain Business Logic & Safety Rules

The security companion app enforces strict domain invariants during arming operations:

### Arming Safety Matrix

| Current State | Battery Level | Sensor Contact State | Action Attempted | Result | Triggered Error / Side-Effect |
| :---: | :---: | :---: | :---: | :---: | :--- |
| **Disarmed** | $\ge 15\%$ | Clear / Closed | Arm Zone | **Success** | `zone.isArmed = true`, `EventLog(info)` created |
| **Disarmed** | $< 15\%$ | Clear / Closed | Arm Zone | **BLOCKED** | `SecurityArmError.lowBattery`, modal alert displayed |
| **Disarmed** | $\ge 15\%$ | Tripped / Open | Arm Zone | **BLOCKED** | `SecurityArmError.sensorTripped`, modal alert displayed |
| **Disarmed** | $< 15\%$ | Tripped / Open | Arm Zone | **BLOCKED** | First failing sensor aborts transaction |
| **Armed** | Any | Any | Disarm Zone | **Success** | `zone.isArmed = false`, `EventLog(warning)` created |

> [!IMPORTANT]
> **Safety Invariant**: Disarming a zone is never restricted by sensor health or battery status. Failsafe disarming ensures an operator can always silence or neutralize an active zone.

---

## 6. Asynchronous Telemetry & Networking Architecture

Remote telemetry streaming is decoupled from the user interface using modern **Swift Concurrency**:

```mermaid
sequenceDiagram
    autonumber
    actor User as Operator / Background Task
    participant View as EventFeedView
    participant Service as SecurityFeedService
    participant Network as URLSession (Shared)
    participant API as Free Mock REST API (JSONPlaceholder)

    User->>View: App Launch (.task) or Pull-to-Refresh (.refreshable)
    View->>Service: fetchRecentAlerts() (async)
    Service->>Network: data(from: endpoint)
    Network->>API: GET /posts?_limit=10
    API-->>Network: HTTP 200 OK + JSON Payload
    Network-->>Service: (Data, HTTPURLResponse)
    Service->>Service: JSONDecoder().decode([RemoteSecurityAlertDTO].self)
    Service-->>View: Returns [RemoteSecurityAlertDTO]
    View-->>User: Renders Live Telemetry Stream with Pulsing Green Indicator
```

### Networking Best Practices Implemented
- **Structured Concurrency**: Network invocations are bound to SwiftUI view lifecycles via `.task` and `.refreshable`, guaranteeing automatic cooperative task cancellation when navigating away.
- **HTTP Validation**: Explicitly verifies `200...299` HTTP status codes before invoking `JSONDecoder`.
- **Zero Third-Party Dependencies**: Built on standard `Foundation.URLSession`, requiring no CocoaPods, SPM packages, or external SDK overhead.

---

## 7. Presentation Layer & UI Architecture

The UI adheres strictly to human interface guidelines (HIG) while delivering a purpose-built cybersecurity aesthetic:

```
SecureNest Navigation & View Hierarchy
│
├── LoginView (Root Gateway when unauthenticated)
│   ├── Ambient Background Glow Spheres (Blur 80pt)
│   ├── Hero Shield Container (88x88pt Linear Gradient)
│   ├── PIN Input with Show/Hide Password Toggle
│   ├── Evaluation Shortcut (Auto-fill Demo PIN 4829)
│   └── Gateway Security Footer (Online • AES-256 • SwiftData)
│
└── Main TabView (Presented upon authentication, Tint: Theme.cyberBlue)
    │
    ├── Tab 1: ZoneListView (NavigationStack)
    │   ├── Toolbar: Principal Shield Branding & "+ Add Zone" Primary Action
    │   ├── SystemStatusBanner (Dynamic System-Wide Health State)
    │   ├── QuickMetricsRow (4-Pillar KPI Tiles: Armed, Disarmed, Alerts, Low Bat)
    │   ├── FilterBar (All / Armed / Disarmed / Alerts)
    │   ├── Live SearchBar (Instant name & location filtering)
    │   ├── ForEach(ZoneItem) -> Custom Zone Cards with Quick Arm Button
    │   │   └── ContextMenu: Quick Arm/Disarm, Delete Zone
    │   └── Sheet: AddZoneSheet (Custom Hardware Enrollment)
    │       └── Navigates to -> ZoneDetailView (via .navigationDestination)
    │           ├── HeroStatusSection (80x80 Double-Ring Badge + Status Capsule)
    │           ├── ArmingControlsSection (Arm/Disarm Toggle with Error Alerts)
    │           ├── SensorsSection (Hardware Telemetry, Battery Gauges)
    │           │   └── Interactive Evaluator Simulators: "Simulate Trip" & "Drop Battery <15%"
    │           ├── TelemetryTimelineSection (Visual 24h Hourly Gradient Bar Chart)
    │           ├── HardwareDiagnosticsSection (Ping Zone Latency & 85dB Chime Test)
    │           └── Sheet: AddSensorSheet (Enroll additional sensors to zone)
    │
    ├── Tab 2: EventFeedView (NavigationStack)
    │   ├── Toolbar: Export Audit Log (ShareLink) & Clear Logs
    │   ├── CriticalAlertBanner (Sticky glowing alert when tripped zones exist)
    │   ├── LiveHeaderCard (Animated Pulsing Live Dot + REST Gateway info)
    │   ├── FilterBar (All / Live Cloud / Hardware Logs)
    │   ├── Live Cloud Stream Section (Decoded RemoteSecurityAlertDTOs via async/await)
    │   └── Local Hardware Incident Section (SwiftData EventLogs with severity badges)
    │
    └── Tab 3: SettingsView (NavigationStack)
        ├── SecOps Supervisor Profile Card (Admin Privileges)
        ├── SecurityPostureCard (Presets: Balanced, Lockdown, Night Guard)
        ├── PreferencesCard (Push Notifications & PIN enforcement toggles)
        ├── DataManagementCard (Live SwiftData Metrics, Reset Sample Data, Clear Logs)
        ├── AboutCard & Export Diagnostics (ShareLink system diagnostic report)
        └── SignOutButton (Destructive session logout returning to LoginView)
```

---

## 8. Automated Testing Strategy (XCTest)

The project includes an isolated, reproducible automated test suite located in `SecureNestTests/ZoneLogicTests.swift`.

### Test Architecture Highlights
- **In-Memory Store Isolation**: The test harness provisions a fresh `ModelContainer` configured with `isStoredInMemoryOnly: true` in `setUpWithError()`:
  ```swift
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  container = try ModelContainer(for: ZoneItem.self, SensorReading.self, EventLog.self, configurations: config)
  context = container.mainContext
  viewModel = ZoneViewModel()
  ```
  This guarantees test runs produce zero filesystem side-effects and run hermetically in parallel.
- **Teardown Cleanup**: All references (`viewModel`, `container`, `context`) are explicitly nulled in `tearDownWithError()`.

### Test Suite Coverage

| Test Method | Scenario Evaluated | Expected Outcome |
| :--- | :--- | :--- |
| `testArmZone_Success` | Zone with healthy sensors ($\ge 15\%$ battery, clear contact) | `zone.isArmed == true`, `errorMessage == nil` |
| `testArmZone_FailsOnLowBattery` | Zone with a sensor exhibiting $10\%$ battery ($< 15\%$) | `zone.isArmed == false`, `errorMessage != nil` |
| `testArmZone_FailsWhenTripped` | Zone with an actively triggered sensor (`isTriggered == true`) | `zone.isArmed == false`, `errorMessage != nil` |
| `testDisarmZone_AlwaysSucceeds` | Previously armed zone receiving a disarm request | `zone.isArmed == false`, `errorMessage == nil` |

---

## 9. Architectural Trade-offs & Decisions

| Decision | Chosen Approach | Alternative Considered | Rationale |
| :--- | :--- | :--- | :--- |
| **Persistence** | **SwiftData** (`@Model`) | Core Data (`.xcdatamodeld`) | Native Swift-first modeling, zero XML/model compiler friction, seamless SwiftUI `@Query` reactivity. |
| **Observation** | **SwiftUI `@Observable`** | Combine `ObservableObject` | Lower memory footprint, fine-grained property-level view invalidation, no manual `AnyCancellable` subscription leaks. |
| **Concurrency** | **Structured `async/await`** | Completion Handlers / GCD | Prevents callback hell, provides compiler-enforced thread safety, automatic task cancellation with view lifecycle. |
| **UI Navigation** | **`NavigationStack` Destinations** | Legacy `NavigationView` | Type-safe value-driven routing (`.navigationDestination(for:)`), programmatic backstack control. |
| **Dependency Injection** | **Environment `\.modelContext`** | Global Singletons | Facilitates clean unit testing using in-memory mock containers without monkey-patching globals. |
