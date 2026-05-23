# Sajda - Comprehensive UI/UX, Copy & Interaction Specification

## 1. Directive for AI Agent
Do not make independent design decisions. You must implement the exact widget structures, layout dimensions, hexadecimal colors, animation curves, and text copy specified in this document. Sajda is a Flutter mobile application[cite: 1]. The UI must reflect a behavioral intervention tool that is quiet, firm, intentional, and respectful of user autonomy[cite: 1]. Do not use standard Material or Cupertino default animations unless explicitly instructed.

---

## 2. Brand Identity & Logo Specification

Sajda prioritizes identity formation over gamification[cite: 1]. The branding must not contain bright colors, badges, or complex illustrations.

### 2.1 App Icon & Logo
*   **Concept:** A minimalist, continuous monoline drawing of a 'Mihrab' (prayer niche) arch, doubling as a sunrise horizon line.
*   **Implementation (Flutter `CustomPaint` or SVG):**
    *   Shape: A semi-circle arch resting on a horizontal baseline.
    *   Stroke Width: `2.0` logical pixels.
    *   Stroke Cap: `StrokeCap.round`.
    *   Color: `textPrimaryLight` (light mode) / `textPrimaryDark` (dark mode).
    *   Background: Solid `bgPrimaryLight` or `bgPrimaryDark`. No gradients.
*   **Usage:** Used only on the splash screen and as the primary device app icon. Never used as a decorative element inside the app.

---

## 3. Global Design Tokens (Flutter Specific)

### 3.1 Colors (`AppColors` class)
*   `bgPrimaryLight`: `Color(0xFFF7F5F2)` (Sand/Alabaster)
*   `bgPrimaryDark`: `Color(0xFF1A1D1E)` (Deep Obsidian)
*   `bgIntervention`: `Color(0xFF232B2F)` (Deep Slate, exclusively for Android Strict Mode[cite: 1])
*   `textPrimaryLight`: `Color(0xFF2B2D2F)`
*   `textSecondaryLight`: `Color(0xFF6B7276)`
*   `textPrimaryDark`: `Color(0xFFEAEBEB)`
*   `textSecondaryDark`: `Color(0xFFA0A6A9)`
*   `textIntervention`: `Color(0xFFF7F5F2)`
*   `accentPrimary`: `Color(0xFF748670)` (Subdued Sage)
*   `actionDestructive`: `Color(0xFF8E4A49)` (Muted Rust)

### 3.2 Typography (`AppTextStyles` class via GoogleFonts)
*   `displayLarge`: Inter, 48px, w600, letterSpacing: -0.96
*   `heading1`: Inter, 24px, w500, letterSpacing: -0.24
*   `heading2`: Inter, 20px, w500, letterSpacing: 0
*   `bodyLarge`: Inter, 16px, w400, height: 1.5
*   `bodyMedium`: Inter, 14px, w400, height: 1.5
*   `reflection`: Lora, 18px, w400, fontStyle: italic, height: 1.6
*   `button`: Inter, 14px, w500, letterSpacing: 0.28, uppercase

### 3.3 Spacing & Layout Tokens
*   `paddingScreenHorizontal`: `24.0`
*   `spacingXs`: `4.0`, `spacingSm`: `8.0`, `spacingMd`: `16.0`, `spacingLg`: `24.0`, `spacingXl`: `32.0`, `spacingXxl`: `48.0`
*   `radiusButton`: `8.0`, `radiusCard`: `12.0`, `radiusPill`: `999.0`

---

## 4. Motion & Animation Controller Specifications

Animations must never be bouncy or springy. The system must feel heavy and deliberate.

### 4.1 Page Transitions
*   **Type:** Cross-fade.
*   **Implementation:** Use `PageRouteBuilder` with a `FadeTransition`.
*   **Duration:** `Duration(milliseconds: 400)`.
*   **Curve:** `Curves.easeInOutCubic`.

### 4.2 Escape Hatch Hold Animation (Android)
*   **Controller:** `AnimationController(duration: Duration(seconds: 5))`.
*   **Curve:** `Curves.linear`. (Must be perfectly linear so the user can accurately judge the 5 seconds)[cite: 1].
*   **Reverse Duration:** `Duration(milliseconds: 200)` if released early.

### 4.3 Element Fade-Ins (Reflection Text, Setup Completion)
*   **Type:** Opacity fade combined with a microscopic upward translation.
*   **Implementation:** `FadeTransition` + `SlideTransition` (from `Offset(0, 0.05)` to `Offset.zero`).
*   **Duration:** `Duration(milliseconds: 800)`.
*   **Curve:** `Curves.easeOutQuart`.

---

## 5. Screen Layouts & Exact Copy

### 5.1 Onboarding Flow
The goal is pre-commitment. Users opt into structure once[cite: 1].

**Screen 1: The Philosophy**
*   **Layout:** Center-aligned `Column`.
*   **Copy:**
    *   Title (`heading1`): `"Friction over force."`
    *   Body (`bodyLarge`): `"Sajda does not force you to pray. It simply removes the digital noise during salah, making the choice to pray the easiest path."`
*   **Action (`PrimaryButton`):** `"UNDERSTAND & CONTINUE"`

**Screen 2: Identity Formation**
*   **Layout:** Center-aligned `Column`.
*   **Copy:**
    *   Title (`heading1`): `"A Quiet Shift."`
    *   Body (`bodyLarge`): `"This tool is built to reinforce one truth: I am someone who prays on time."`[cite: 1]
*   **Action (`PrimaryButton`):** `"COMMIT TO STRUCTURE"`

**Screen 3: Permissions (Platform Adaptive)[cite: 1]**
*   **Layout:** Left-aligned `Column`.
*   *If iOS:*
    *   Title (`heading1`): `"Define your boundaries."`
    *   Body (`bodyLarge`): `"Select apps to block during salah."`[cite: 1]
    *   Action (`PrimaryButton`): `"CHOOSE DISTRACTIONS"` (Triggers FamilyControls API)[cite: 1]
*   *If Android:*
    *   Title (`heading1`): `"Enable the environment."`
    *   Body (`bodyLarge`): `"Sajda requires accessibility and overlay permissions to create a distraction-free space during prayer windows."`
    *   Action (`PrimaryButton`): `"GRANT PERMISSIONS"`

### 5.2 Home Screen
*   **Layout:** Centered content with top-right settings icon.
*   **Copy (Dynamic based on time):**
    *   Label (`bodyMedium`, `textSecondaryLight`): `"Next Prayer"`
    *   Prayer Name (`heading1`): e.g., `"Dhuhr"`
    *   Time (`displayLarge`): e.g., `"12:30 PM"`
    *   Streak Indicator (`bodyMedium`, `accentPrimary`): `"12 Day Streak"`[cite: 1]
*   **Empty State (If all prayers completed):**
    *   Title (`heading1`): `"Rest."`
    *   Body (`bodyLarge`): `"All prayers for today are complete."`

### 5.3 Intervention Overlay (Android Strict Mode)[cite: 1]
This screen blocks all interaction except allowed apps[cite: 1].
*   **Background:** `bgIntervention`.
*   **Layout:** Centered.
*   **Copy:**
    *   Status (`heading2`, `textIntervention`): `"{Prayer Name} is happening now."` (e.g., `"Asr is happening now."`)
    *   Countdown (`displayLarge`, tabular figures): `"14:59"`
    *   Context (`bodyMedium`, `textSecondaryDark`): `"Remaining in window"`
*   **The Escape Hatch (`GestureDetector` at bottom of screen)[cite: 1]:**
    *   Text (`bodyMedium`, `actionDestructive`): `"Press and hold to exit"`

### 5.4 System Restriction Screen (iOS Structured Mode)[cite: 1]
Since iOS uses system-level blocking, the app cannot draw a custom UI over blocked apps[cite: 1]. However, provide the exact copy for the iOS Notification that triggers at prayer time.
*   **Notification Title:** `"It is time for {Prayer Name}."`
*   **Notification Body:** `"Your selected apps have been paused. Take this moment to pray."`

### 5.5 Post-Intervention Reflection Screen[cite: 1]
Appears after the restriction window or manual override.
*   **Layout:** Centered `Column`.
*   **Animation:** Text fades in (`Duration: 800ms`). Button fades in 2 seconds *after* the text.
*   **Copy (Randomize between these strings, `AppTextStyles.reflection`):**
    *   `"Indeed, prayer has been decreed upon the believers a decree of specified times."`
    *   `"Success is not in the abundance of motion, but in the precision of your pause."`
    *   `"The world can wait. This moment cannot."`
*   **Action (`TextButton`):** `"Close"` (Style: `button`, Color: `textSecondaryLight`).

### 5.6 Settings Screen
*   **Layout:** Standard `ListView` with `ListTile` widgets.
*   **Section 1: General**
    *   Item: `"Prayer Calculation Method"` (Subtitle: e.g., `"Muslim World League"`)
    *   Item (iOS Only): `"Manage Blocked Apps"`[cite: 1]
*   **Section 2: Danger Zone**
    *   Item: `"Reset Streaks"` (Color: `actionDestructive`)