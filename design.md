# Product: Sajda (working name)

## 1. Overview

Sajda is a minimal mobile app that helps Muslims pray on time by reducing access to distractions during salah windows.

It is not a reminder app.
It is a behavioral intervention tool.

Core idea:
At prayer time, the system introduces enough friction to create a natural transition into prayer.

This friction is implemented differently depending on platform capabilities.

---

## 2. Product Philosophy (Updated)

Sajda is built on three behavioral principles:

### 2.1 Friction Over Force
The goal is not to force compliance, but to make distraction harder than prayer.

---

### 2.2 Pre-Commitment
Users opt into structure once.
The system executes automatically without repeated consent.

---

### 2.3 Platform-Adaptive Enforcement
Different platforms provide different levels of control.

Sajda does not aim for identical behavior across platforms.
It aims for the same *outcome* using different mechanisms.

---

### 2.4 Identity Formation Over Gamification
The product reinforces:
> “I am someone who prays on time”

Not:
- rewards
- points
- flashy achievements

---

## 3. Target User

(Unchanged)

---

## 4. Platform Strategy (Updated)

### Android (Primary Platform - v1)

- Full behavioral enforcement possible
- Used to validate core mechanic

---

### iOS (Secondary Platform - Adapted Experience)

Due to OS restrictions:
- Full device lock is not possible
- Overlay control is not possible

Instead:
- System-level app restriction (Screen Time APIs)
- Structured distraction blocking

---

## 5. Tech Stack (Updated)

### Mobile
- Flutter (shared UI layer)

---

### Platform-Specific Layers

#### Android:
- Accessibility Service
- Overlay system
- AlarmManager

#### iOS:
- FamilyControls API
- DeviceActivity API
- ManagedSettings API

---

### Local Storage
- SQLite / Hive

---

### Backend
- None (v1)

---

## 6. Core Features (Updated)

### 6.1 Prayer Time Tracking
(Unchanged)

---

### 6.2 Distraction Control System (Core Feature)

This replaces "Lock System" as a broader concept.

#### Android Implementation:
- Full-screen lock overlay
- Blocks all interaction except allowed apps

#### iOS Implementation:
- Blocks selected distraction apps using system APIs
- No full-screen lock

---

### 6.3 Escape Hatch

(Unchanged in principle, platform-specific in execution)

#### Android:
- 5-second hold + confirmation

#### iOS:
- System-level override (requires navigating settings)
- Higher friction by design

---

### 6.4 Post-Intervention Reflection

(Unchanged)

---

### 6.5 Streak Tracking

(Unchanged, but more important on iOS due to weaker enforcement)

---

## 7. UX Flow (Platform-Aware)

---

### 7.1 Onboarding (Updated)

#### Screen 3: Setup

Add:

- On iOS:
  - “Select apps to block during salah”
  - Triggers system permission flow

---

### 7.2 Home Screen

(Unchanged)

---

### 7.3 Intervention Experience (Updated)

#### Android:
- Full-screen lock overlay
- Countdown timer
- Minimal UI

---

#### iOS:
- No overlay

Instead:
- User attempts to open blocked app
- System displays restriction screen

App supplements with:
- Notification at prayer time
- Optional deep link into app

---

### 7.4 Post-Lock / Post-Window

(Unchanged)

---

### 7.5 Daily Summary

(Unchanged)

---

### 7.6 Settings (Updated)

Add:
- App selection (iOS only)
- Toggle enforcement strength (future)

---

## 8. Design System

(Unchanged)

---

## 9. System Architecture (Updated)

### High-Level


---

### Core Services

- PrayerTimeService
- StreakService
- NotificationService

Platform-specific:
- AndroidLockService
- iOSRestrictionService

---

## 10. Enforcement Mechanisms

---

### 10.1 Android (Strict Mode)

Capabilities:
- Full app blocking
- Overlay control
- Background scheduling

Flow:
1. Trigger at prayer time
2. Show overlay
3. Block interaction
4. Timer runs
5. Reflection

---

### 10.2 iOS (Structured Mode)

Capabilities:
- App-level blocking only

Flow:
1. Pre-scheduled restriction window
2. Selected apps become unavailable
3. User encounters system restriction screen
4. App provides reflection afterward

---

## 11. Data Model

(Unchanged)

---

## 12. Core Logic

(Unchanged)

---

## 13. Edge Cases (Updated)

Add:

### iOS-specific:
- User revokes Screen Time permissions
  → Prompt re-enable

- Partial app blocking
  → Ensure critical apps (calls) not affected

---

## 14. MVP Scope (Updated)

### Android:
- Full implementation

### iOS:
- App blocking
- Reflection
- Streaks

---

## 15. Success Metrics (Updated)

Add:

- % of users completing all prayers daily
- Skip / override rate (Android)
- App open attempts during restriction (iOS)

---

## 16. Future Ideas

Add:

- Adaptive restriction strength
- Personalized friction tuning
- Cross-platform sync (optional)

---

## Final Note (Updated)

The product should feel:

- Quiet
- Firm
- Intentional
- Respectful of autonomy

Not:

- Punitive
- Manipulative
- Overbearing

The goal is not control.

The goal is:
> creating a moment where choosing to pray becomes the easiest path.