# SecureNest: Demo Video Presentation Script & Guide

**Target Duration**: 2.5 – 3 minutes  
**Goal**: Clearly demonstrate all 6 assignment requirements with engaging commentary and smooth simulator navigation.

---

## Pre-Recording Checklist
- [ ] Open Xcode with the project loaded.
- [ ] Reset Simulator to default state (or tap "Reset Sample Data" in Settings).
- [ ] Make sure the Simulator is set to 100% scale and sound/microphone is clear.
- [ ] Have the Test Navigator (<kbd>Cmd</kbd> + <kbd>6</kbd>) ready in Xcode for the final test run.

---



## Scene-by-Scene Script

### Scene 1: Introduction (0:00 – 0:25)
**Screen**: App starting on the Login Screen.  
**Script**:
> *"Hello! Today I'm presenting **SecureNest**, a native iOS Security Monitoring Companion app. It is built entirely in SwiftUI using modern declarative UI, native SwiftData for offline-first persistence, and Swift Concurrency with `async/await` for live telemetry feeds. The app follows a clean MVVM architecture with strict business logic governing zone arming and safety validation."*

---

### Scene 2: Mock Login & Security Terminal (0:25 – 0:45)
**Screen**: LoginView.  
**Actions**:
1. Point out the cybersecurity styling, ambient glow spheres, and terminal status footer (`GATEWAY ONLINE • AES-256 • SWIFTDATA PERSISTED`).
2. Type or show the PIN field, and tap the eye icon to reveal the password.
3. Tap **"Auto-fill Default PIN (4829)"**.
4. Tap **"Authorize Terminal Gateway"**.  
**Script**:
> *"We start at the Terminal Gateway. Here we have a styled login screen with masked input, a password visibility toggle, and evaluation shortcuts. Tapping 'Authorize Terminal Gateway' validates our credentials and transitions us into the main companion interface via NavigationStack."*

---

### Scene 3: Monitored Zone List & CRUD Enrollment (0:45 – 1:15)
**Screen**: ZoneListView (Zones tab).  
**Actions**:
1. Point to the **System Status Banner** and the **4-Pillar KPI Metrics Dashboard** (Armed, Disarmed, Alerts, Low Bat).
2. Tap the filter chips (`All`, `Armed`, `Disarmed`, `Alerts`) and type a letter in the search bar.
3. Tap the quick-arm button on **North Perimeter** to arm it.
4. Tap **"+ Add Zone"** in the toolbar, type `Patio Door`, select `Door Sensor`, and tap **"Enroll Security Zone"**.  
**Script**:
> *"Here on the Security Zones dashboard, operators see real-time system health at a glance with our status banner and 4-pillar KPI metrics. We have responsive filter chips and live search. Tapping the lock icon toggles arming with instant feedback. And tapping '+ Add Zone' opens our enrollment sheet, which persists new hardware zones directly into SwiftData with cascade relationships."*

---

### Scene 4: Zone Detail & Arming Safety Validation (1:15 – 1:55)
**Screen**: Tap into **"Data Vault"** (has the low battery sensor).  
**Actions**:
1. Show the 80×80 sensor badge and armed state.
2. Tap **"Arm Zone Secure"** -> An error alert pops up: *"Cannot arm: PIR Motion battery is below 15%."*
3. Tap **"Recharge Battery"** on the PIR Motion sensor.
4. Tap **"Arm Zone Secure"** again -> Now it arms successfully!
5. Scroll down to show the **24-Hour Telemetry Timeline** (hourly activity bars).
6. Tap **"Test Chime"** to show the 85dB chime simulation and audio wave animation.  
**Script**:
> *"Next, we drill down into the Zone Detail screen using NavigationStack. Notice our safety validation: when I attempt to arm 'Data Vault', the app blocks arming because the sensor battery is below 15%, preventing false security. Using our built-in simulator button, I'll recharge the battery — and now it arms immediately! Below, we have a 24-hour visual telemetry timeline and an interactive chime sound test that emits a simulated 85dB tone."*

---

### Scene 5: Live Event Feed via `async/await` (1:55 – 2:20)
**Screen**: Switch to the **Live Feed** tab (EventFeedView).  
**Actions**:
1. Point out the pulsing green live dot and the cloud telemetry gateway info.
2. Tap **"Fetch Batch"** (or pull-to-refresh) -> Live alerts from JSONPlaceholder load via `async/await`.
3. Scroll to show local SwiftData hardware logs.
4. Open the top-right menu and highlight **"Export Audit Log"**.  
**Script**:
> *"Moving to the Live Event Feed, this screen consumes a free public REST API using Swift Concurrency `async/await` and URLSession. Notice the animated live status dot. Pulling down or tapping 'Fetch Batch' streams remote alerts asynchronously. Below, native SwiftData logs our local arm and disarm audit trail. We also have an 'Export Audit Log' feature via ShareLink."*

---

### Scene 6: Settings Screen & Diagnostics (2:20 – 2:40)
**Screen**: Switch to the **Settings** tab (SettingsView).  
**Actions**:
1. Point to the SecOps Admin profile card.
2. Tap through the **Security Posture Profiles** (`Balanced`, `Lockdown`, `Night Guard`).
3. Show SwiftData database metrics (persisted zones and stored event count).
4. Tap **"Export System Diagnostics Report"** to show the native Share sheet.  
**Script**:
> *"In the Settings screen, operators can adjust security posture presets between Balanced, Lockdown, and Night Guard. We display live SwiftData persistence metrics, options to reset sample data or clear logs, and an Export Diagnostics Report feature."*

---

### Scene 7: Automated Unit Tests & Conclusion (2:40 – 3:00)
**Screen**: Switch from Simulator to Xcode, showing `ZoneLogicTests.swift`.  
**Actions**:
1. Press <kbd>Cmd</kbd> + <kbd>U</kbd> to run the test suite.
2. Show all 4 tests passing with green checkmarks.  
**Script**:
> *"Finally, here in Xcode, we have our automated XCTest suite covering the arm and disarm safety logic using an in-memory SwiftData container. Running the tests with Command-U confirms all 4 test cases pass cleanly: successful arming, low-battery rejection, tripped sensor rejection, and disarming. Thank you!"*
