## UX Design

DevAutoFlow is a lightweight developer platform for running AI-powered Android automation across connected devices through ADB and MCP. The experience should feel direct, fast, and focused on configuration and execution rather than generic admin tooling.

### UX Principles

- Clean and minimal interface
- Desktop-first, with tablet support
- Clear visual hierarchy
- Lightweight motion and smooth state transitions
- Few screens, focused workflow
- Show only the information needed for the current task
- Make device, APK, run, and agent states immediately understandable
- Intentionally avoid a heavy dashboard/admin experience

### Core User Flow

```text
Login / Signup
  ↓
Dashboard
  ↓
Select Devices
  ↓
Upload APKs (optional)
  ↓
Assign APKs per device
  ↓
Enter scenario and LLM key
  ↓
Run Test
  ↓
Execution Screen
  ↓
View Logs / Results
  ↓
Runs History
```

The overall experience should feel like:

**Configure → Run → Observe → Result**

---

### Application Navigation

The product contains a small but clear navigation model:

```text
Dashboard
Runs
Settings
Profile / Logout
```

#### Dashboard

The Dashboard is the primary workspace for configuring a run.

```text
Dashboard
├── Connected devices
├── APK library
├── APK assignment per device
├── AI scenario prompt
├── LLM configuration
├── Run action
└── Execution summary
```

---

### Authentication UX

Users should first see a minimal auth screen for signup or login.

```text
Sign in / Create account
- Email or username
- Password
- Submit
```

This screen should be quick and clean. It should not distract from the automation workflow.

---

### Device UX

Connected Android devices are displayed as cards.

Each device card shows:

- Device model
- Device ID
- Android version
- Connection status
- Selection state

Example:

```text
┌─────────────────────┐
│ ● Pixel 7           │
│   Android 15        │
│   Connected         │
│                     │
│   ✓ Selected        │
└─────────────────────┘
```

Users may select multiple devices. Device selection is independent from APK assignment, which allows the system to run automation against:

- existing apps already installed on the device
- Chrome
- Android Settings
- other system or user-installed apps

A device can be selected even when no APKs are assigned.

---

### APK UX

Users can upload one or more APKs.

Each APK is shown with a simple numeric identifier used for assignment.

```text
① chat.apk
② payment.apk
③ shopping.apk
```

Each item should show:

- Number
- Filename
- File size
- Status
- Remove action

The visual design should stay lightweight and clear, with no heavy file management UI.

---

### APK Assignment UX

For every selected device, the user can choose which uploaded APKs should be installed on that device.

```text
Device          Assigned APKs
────────────────────────────────────
Pixel 7         [①] [②] [③]
Galaxy S24      [①] [②]
OnePlus 12      [①]
```

A selected APK should have a strong active state, while an unselected APK should read as neutral.

Example:

```text
Pixel 7
[ ① ]  [ ② ]  [ ③ ]
  ✓      ✓
```

No APK selection is also valid:

```text
Pixel 7
APKs: None
```

This means the device may run automation using apps already present on the device without installing a new package.

---

### LLM and Scenario UX

The dashboard includes a simple configuration area for the LLM.

```text
LLM Provider
[ OpenAI ▼ ]

API Key
[ *********************** ]

[ Save ]
```

Below that, the user enters a natural-language scenario.

```text
Describe the automation you want the agents to perform...

Login as User A on Device A and User B on Device B.
Send an initial message and verify that the reply is received.
```

This area should visually emphasize that the scenario is executed by AI agents operating across devices.

---

### Run UX

The primary action is:

```text
▶ Run Test
```

Before starting a run, the UI should validate:

- at least one device is selected
- a scenario is provided
- LLM configuration is available
- APK assignment is optional but allowed

After clicking Run Test, the interface should immediately move into a running state with a clear loading transition.

```text
Run Test
  ↓
Creating run
  ↓
Validating devices
  ↓
Starting agents
  ↓
Running
```

The button should progress smoothly from:

```text
▶ Run Test
```

to:

```text
⟳ Starting...
```

Double-clicking should not create duplicate runs.

---

### Execution UX

The execution page provides a real-time view of the current run.

```text
RUN-01KABC123
● RUNNING

Devices
────────────────────────────────────────────────

┌─────────────────┐  ┌─────────────────┐
│ Pixel 7         │  │ Galaxy S24      │
│ ● Running       │  │ ● Running       │
│                 │  │                 │
│ Device Screen   │  │ Device Screen   │
└─────────────────┘  └─────────────────┘

Agent Status
────────────────────────────────────────────────

Pixel 7     Observing screen...
Galaxy S24  Waiting for message...

Recent Actions
────────────────────────────────────────────────

✓ Launching application
✓ Opening conversation
→ Sending message
○ Verifying delivery

[ Stop Run ]
```

This page should stay compact, legible, and responsive without feeling like a large monitoring dashboard.

---

### Agent State UX

Agent activity should be represented with simple states:

```text
Observing
Thinking
Executing
Verifying
Completed
Failed
```

Example:

```text
● Observing
○ Thinking
○ Executing
○ Verifying
```

or:

```text
✓ Observing
✓ Thinking
→ Executing
○ Verifying
```

The current state should be visually highlighted without overusing animation.

---

### Device Status UX

Devices should provide clear execution states:

```text
Queued
Installing
Running
Passed
Failed
```

Example:

```text
Pixel 7
● Running

Galaxy S24
✓ Passed

OnePlus 12
✕ Failed
```

---

### Logs UX

Execution logs should appear cleanly and be easy to scan.

```text
12:31:04  Pixel 7     Launching chat.apk
12:31:06  Pixel 7     Opening login screen
12:31:09  Pixel 7     Entering username
12:31:12  Galaxy S24  Waiting for message
12:31:15  Pixel 7     Sending message
12:31:17  Galaxy S24  Message received
```

Each log entry should identify the device responsible for the action.

---

### Result UX

When the run ends, the interface should clearly show the final outcome.

#### Successful run

```text
✓ Test Passed

Chat message successfully delivered.

Pixel 7       ✓ Passed
Galaxy S24    ✓ Passed

Duration: 42s
```

#### Failed run

```text
✕ Test Failed

Message delivery could not be verified.

Pixel 7       ✓ Passed
Galaxy S24    ✕ Failed

View execution logs →
```

The result area should prioritize the final outcome while still allowing inspection of the per-device result.

---

### Runs UX

The Runs page shows previous executions.

```text
Runs

RUN ID          STATUS       DEVICES       TIME
────────────────────────────────────────────────────
01KABC123       ✓ Passed     2 devices     2 min ago
01KABC456       ✕ Failed     3 devices     1 hour ago
01KABC789       ✓ Passed     1 device      Yesterday
```

Selecting a run opens its details, logs, and final result.

---

### Settings UX

Settings should stay simple and direct.

```text
Settings

LLM Provider
[ OpenAI ▼ ]

API Key
[ *********************** ]

[ Save ]
```

Account details can remain secondary:

```text
Account
Email
Username

[ Logout ]
```

API keys should never be displayed in plaintext after saving.

---

### Interaction and Motion

This product uses a lightweight UI approach with React, Vite, and Tailwind CSS. Motion should be subtle and purposeful.

Animation guidance:

- Typical transitions: 150-250ms
- Device cards should appear smoothly when loaded
- Selection states should change with clear border and color transitions
- APK assignment should feel immediate and obvious
- Run button should have loading and success/error feedback
- Execution states should transition smoothly
- Logs should appear without large layout jumps
- Success/failure states should use subtle transitions
- Error states should remain visible and readable

Avoid:

- heavy 3D effects
- excessive motion
- distracting backgrounds
- long transitions
- unnecessary visual noise

---

### Responsive UX

The primary target is desktop because DevAutoFlow is a developer tool. Tablet support should also be considered.

On smaller screens:

- device cards can stack vertically
- APK assignment can become a stacked layout
- execution panels can stack vertically
- logs remain scrollable
- primary actions remain easy to access

---

### Information Architecture Summary

```text
Auth
  └── Login / Signup

Dashboard
  ├── Devices
  ├── APK Library
  ├── APK Assignment
  ├── LLM Configuration
  ├── Scenario Input
  └── Run Button

Execution
  ├── Device panels
  ├── Agent status
  ├── Activity feed
  ├── Logs
  └── Stop Run

Runs
  └── Historical execution list + detail

Settings
  ├── LLM provider
  ├── API key
  └── Account controls
```

The entire UX should feel minimal, confident, and execution-first: the user configures an automation run, starts it, watches progress, and reviews results without dealing with unnecessary app complexity.

