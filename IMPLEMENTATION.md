# DevAutoFlow

**DevAutoFlow — AI-powered autonomous automation for real Android devices.**

DevAutoFlow is a lightweight web-based platform for running AI-driven automation scenarios on Android devices connected to a Linux machine through **ADB**.

Users can:

* Create an account and log in.
* See Android devices connected through ADB.
* Select multiple Android devices.
* Upload/select multiple APKs.
* Assign selected APKs independently to each device.
* Provide a natural-language automation/test scenario.
* Provide their own LLM API key.
* Start an automation run.
* Receive a unique `run_id`.
* Monitor execution status.
* Poll execution results using the `run_id`.
* View device screenshots during execution.
* use MCP to allow AI agents to control each device.
* use postgres to store user , runs, llms api keys info 

The project should remain **simple and lightweight**. Do not introduce unnecessary microservices, queues, Kubernetes, Redis, Kafka, or complicated infrastructure in the initial version.

---

# 1. High-Level Architecture

```text
                    ┌─────────────────────┐
                    │      Frontend       │
                    │                     │
                    │ Login / Signup      │
                    │ Device Selection    │
                    │ APK Selection       │
                    │ APK Assignment      │
                    │ LLM Key              │
                    │ Test Scenario       │
                    │ Run                 │
                    │ Results             │
                    └──────────┬──────────┘
                               │
                          REST / WS
                               │
                    ┌──────────▼──────────┐
                    │     ORCH Service    │
                    │      FastAPI        │
                    │                     │
                    │ Auth                │
                    │ Device Manager      │
                    │ APK Manager         │
                    │ Run Manager         │
                    │ Agent Manager       │
                    │ MCP Integration     │
                    └───────┬───────┬─────┘
                            │       │
                            ▼       ▼
                       PostgreSQL   MCP
                                     │
                                     ▼
                                    ADB
                                     │
                         ┌───────────┼───────────┐
                         ▼           ▼           ▼
                      Device A    Device B    Device C
```

---

# 2. Services

Keep the initial project to only:

```text
1. Frontend
2. ORCH / FastAPI backend
3. PostgreSQL
4. Existing MCP server
```

The MCP server already exists and should be integrated into the ORCH service.

Do not create separate auth, device, run, or agent microservices.

These should simply be modules inside the FastAPI application.

---

# 3. Frontend

Use:

* React
* TypeScript
* Vite
* Tailwind CSS
* Lightweight animations

Animations should be subtle and useful.

Examples:

* Device cards appearing smoothly.
* Run button loading animation.
* Device execution status transitions.
* APK assignment selection animation.
* Live status changes.

Do not use heavy animations or unnecessary UI libraries.

---

# 4. Authentication

The application must support:

### Signup

User provides:

```text
Username
Email
Password
```

### Login

User provides:

```text
Email / Username
Password
```

Credentials must be stored in PostgreSQL.

Passwords must **never be stored as plain text**.

Use a secure password hashing method such as Argon2 or bcrypt.

Use JWT authentication for the initial version.

---

# 5. LLM API Keys

Users should be able to provide their own LLM API key through the UI.

Example:

```text
Settings

LLM Provider:
[ OpenAI ]

API Key:
[ *********************** ]

[ Save ]
```

The backend should associate the key with the authenticated user.

Do not return the complete API key to the frontend after saving it.

The API key should preferably be encrypted before being stored in PostgreSQL.

For the initial version, support one LLM provider first.

Design the code so additional providers can be added later.

---

# 6. Android Device Management

Android devices are connected directly to the machine running ADB.

Do **not** use:

* WebUSB
* WebADB
* Browser-based ADB

Use normal system ADB.

Example:

```bash
adb devices -l
```

The backend should discover connected devices.

Example response:

```json
[
  {
    "device_id": "f43dbe44",
    "model": "Pixel 7",
    "android_version": "15",
    "status": "device"
  },
  {
    "device_id": "ABC123",
    "model": "Samsung S24",
    "android_version": "14",
    "status": "device"
  }
]
```

---

# 7. Device Selection

The UI should display all currently connected ADB devices.

Example:

```text
Connected Devices

☑ Pixel 7
  f43dbe44
  Android 15

☐ Samsung S24
  ABC123
  Android 14

☑ OnePlus 12
  XYZ789
  Android 15
```

Users can select multiple devices.

Only selected devices participate in the automation run.

---

# 8. APK Management

Users should be able to select/upload **multiple APKs** from their local system.

Example:

```text
Selected APKs

① chat.apk
② payment.apk
③ shopping.apk
④ maps.apk
```

Each selected APK receives a simple number.

The number is only for UI assignment.

---

# 9. APK Assignment to Devices

This is an important feature.

Each device should display the numbers of all selected APKs below it.

Example:

```text
Selected APKs

① chat.apk
② payment.apk
③ shopping.apk


Device A
┌─────────────────────────┐
│ Pixel 7                 │
│                         │
│ [①] [②] [③]             │
│  🟢   🟢   ⚪            │
└─────────────────────────┘


Device B
┌─────────────────────────┐
│ Samsung S24             │
│                         │
│ [①] [②] [③]             │
│  🟢   ⚪   🟢            │
└─────────────────────────┘
```

Meaning:

```text
Device A:
① chat.apk       → install
② payment.apk    → install
③ shopping.apk   → don't install

Device B:
① chat.apk       → install
② payment.apk    → don't install
③ shopping.apk   → install
```

Clicking/toggling the APK number changes its selected state for that device.

Use a clear visual distinction between selected and unselected.

---

# 10. No APK Assignment

It is completely valid for a device to have **zero APKs assigned**.

Example:

```text
Device A
[①] [②] [③]

All unselected.
```

This means:

> Do not install any uploaded APK on this device.

The agent can use applications already installed on the device.

For example:

* Chrome
* Android Settings
* Existing applications
* Any application already installed on the device

Therefore APK installation is optional.

---

# 11. Run Configuration

The user provides:

```text
Selected devices
+
APK assignments
+
Natural-language scenario
+
LLM provider
```

Example:

```text
Devices:
☑ Device A
☑ Device B

APKs:
① chat.apk
② payment.apk

Device A:
① selected
② selected

Device B:
① selected
② not selected

Scenario:

"Login as User A on Device A and send a message
to User B on Device B. Verify that User B receives
the message."
```

---

# 12. Create Run

Frontend calls:

```http
POST /api/runs
```

Request:

```json
{
  "device_ids": [
    "f43dbe44",
    "ABC123"
  ],
  "apk_assignments": {
    "f43dbe44": ["apk_1", "apk_2"],
    "ABC123": ["apk_1"]
  },
  "prompt": "Login as User A on Device A and send a message to User B on Device B. Verify delivery."
}
```

The backend creates a unique run ID.

Example:

```text
run_01KABC123XYZ
```

Response:

```json
{
  "run_id": "run_01KABC123XYZ",
  "status": "queued"
}
```

The request must return quickly.

Do not make the HTTP request wait until the entire automation finishes.

---

# 13. Run Execution

The ORCH service handles the run.

Flow:

```text
Create Run
    ↓
Validate devices
    ↓
Validate APK assignments
    ↓
Install assigned APKs
    ↓
Create agent for each selected device
    ↓
Connect agent to device MCP
    ↓
Execute scenario
    ↓
Collect results
    ↓
Aggregate results
    ↓
Mark run completed
```

---

# 14. Agent Model

Each selected device gets its own agent.

Example:

```text
run_123

Agent A
device_id = f43dbe44

Agent B
device_id = ABC123
```

Each agent must only control its assigned device.

```text
Agent A → MCP → Device A

Agent B → MCP → Device B
```

An agent must never accidentally control another device.

---

# 15. MCP Integration

The existing MCP server should be integrated into the agent execution flow.

Conceptually:

```text
LangGraph Agent
      ↓
     MCP
      ↓
Android Device Tools
      ↓
     ADB
      ↓
 Android Device
```

The MCP layer should provide device operations such as:

```text
launch_app
tap
swipe
type_text
press_back
screenshot
get_ui_tree
install_apk
```

Use the existing MCP implementation where possible.

Do not rewrite the MCP server unless necessary.

---

# 16. LangGraph

Use LangGraph for the device agent.

Keep the initial graph simple.

```text
START
  ↓
Observe
  ↓
Reason
  ↓
Action
  ↓
Verify
  ↓
Continue / Finish
```

The agent receives:

```text
run_id
device_id
scenario
assigned APKs
MCP tools
```

The agent returns a structured result.

Example:

```json
{
  "device_id": "f43dbe44",
  "status": "passed",
  "summary": "Message successfully sent."
}
```

---

# 17. Agent-to-Agent Communication

A2A communication is **not required for the first implementation**.

The architecture should allow it later.

For now, agents can communicate through the ORCH service.

Example:

```text
Agent A
   ↓
ORCH
   ↓
Agent B
```

Later this can become:

```text
Agent A ←→ A2A ←→ Agent B
```

Communication must be scoped to the current `run_id`.

Agents from different runs must never communicate.

---

# 18. Run Status API

### Get run

```http
GET /api/runs/{run_id}
```

Example:

```json
{
  "run_id": "run_123",
  "status": "running",
  "devices": [
    {
      "device_id": "f43dbe44",
      "status": "running"
    },
    {
      "device_id": "ABC123",
      "status": "completed"
    }
  ]
}
```

Frontend can initially poll this endpoint every 1–2 seconds.

---

# 19. Run Result

```http
GET /api/runs/{run_id}/result
```

Example:

```json
{
  "run_id": "run_123",
  "status": "passed",
  "summary": "Chat message successfully delivered.",
  "devices": [
    {
      "device_id": "f43dbe44",
      "status": "passed"
    },
    {
      "device_id": "ABC123",
      "status": "passed"
    }
  ]
}
```

---

# 20. Run Logs

```http
GET /api/runs/{run_id}/logs
```

Example:

```json
[
  {
    "device_id": "f43dbe44",
    "message": "Launching chat application"
  },
  {
    "device_id": "f43dbe44",
    "message": "Opened conversation with User B"
  },
  {
    "device_id": "ABC123",
    "message": "Message received"
  }
]
```

---

# 21. Stop Run

```http
POST /api/runs/{run_id}/stop
```

The backend should stop the running agents and mark the run:

```text
cancelled
```

---

# 22. Screenshot

Provide:

```http
GET /api/devices/{device_id}/screenshot
```

The backend can use ADB to capture the current screen.

Later the UI can show live screenshots during execution.

---

# 23. Minimal API List

Keep the API simple.

```text
AUTH
POST   /api/auth/signup
POST   /api/auth/login
GET    /api/auth/me


DEVICES
GET    /api/devices
GET    /api/devices/{device_id}/screenshot


APKS
POST   /api/apks
GET    /api/apks
DELETE /api/apks/{apk_id}


LLM
POST   /api/llm-keys
GET    /api/llm-keys
DELETE /api/llm-keys/{provider}


RUNS
POST   /api/runs
GET    /api/runs
GET    /api/runs/{run_id}
GET    /api/runs/{run_id}/result
GET    /api/runs/{run_id}/logs
POST   /api/runs/{run_id}/stop
```

Optional later:

```text
WS /api/runs/{run_id}/events
```

---

# 24. FastAPI Project Structure

Use `uv` for Python dependency and project management.

Create the backend using `uv`.

Recommended structure:

```text
orch/
│
├── pyproject.toml
├── uv.lock
├── .env
├── .env.example
│
├── app/
│   ├── __init__.py
│   ├── main.py
│   │
│   ├── config/
│   │   ├── __init__.py
│   │   └── settings.py
│   │
│   ├── db/
│   │   ├── __init__.py
│   │   ├── database.py
│   │   └── session.py
│   │
│   ├── models/
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── llm_key.py
│   │   ├── apk.py
│   │   └── run.py
│   │
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── device.py
│   │   ├── apk.py
│   │   ├── run.py
│   │   └── llm.py
│   │
│   ├── routers/
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── devices.py
│   │   ├── apks.py
│   │   ├── llm.py
│   │   └── runs.py
│   │
│   ├── services/
│   │   ├── __init__.py
│   │   ├── adb.py
│   │   ├── apk.py
│   │   ├── run.py
│   │   ├── agent.py
│   │   └── mcp.py
│   │
│   ├── agents/
│   │   ├── __init__.py
│   │   ├── graph.py
│   │   └── factory.py
│   │
│   └── core/
│       ├── __init__.py
│       ├── security.py
│       └── dependencies.py
│
└── tests/
```

Do not create additional folders unless they are actually needed.

---

# 25. PostgreSQL Tables

Keep the database minimal.

### users

```text
id
username
email
password_hash
created_at
```

### llm_keys

```text
id
user_id
provider
encrypted_key
created_at
```

### apks

```text
id
user_id
filename
path
created_at
```

### runs

```text
id
user_id
prompt
status
created_at
started_at
completed_at
result
```

### run_devices

```text
id
run_id
device_id
status
result
```

APK assignments can initially be stored with the run/device information rather than creating a complicated relational structure.

Keep the database design simple.

---

# 26. Important Run Model

A run should contain:

```text
run_id
user_id
prompt
selected devices
APK assignments
status
results
```

Example:

```json
{
  "run_id": "run_123",
  "devices": {
    "device_a": ["apk_1", "apk_2"],
    "device_b": ["apk_1"]
  }
}
```

This allows the exact execution configuration to be reproduced.

---

# 27. Frontend Execution Flow

The UI should follow:

```text
Login
  ↓
Dashboard
  ↓
Fetch Devices
  ↓
Select Devices
  ↓
Select APKs
  ↓
Assign APKs to Devices
  ↓
Enter LLM Key
  ↓
Enter Test Scenario
  ↓
Click Run
  ↓
Receive run_id
  ↓
Execution Page
  ↓
Poll run status
  ↓
Show device status
  ↓
Show screenshots
  ↓
Show logs
  ↓
Show final result
```

---

# 28. Example Chat Application Test

User selects:

```text
Device A
Device B
```

Uploads:

```text
① chat.apk
```

Assignment:

```text
Device A → ①
Device B → ①
```

Prompt:

```text
"Login as User A on Device A and User B on Device B.
Send 'Hello' from User A to User B and verify that
User B receives the message. Then reply 'Hi' from
User B and verify that User A receives the reply."
```

DevAutoFlow creates:

```text
run_123

Agent A
 └── Device A
     └── MCP
         └── ADB

Agent B
 └── Device B
     └── MCP
         └── ADB
```

The agents execute the scenario and ORCH aggregates the results.

---

# 29. Implementation Order

Implement in this order.

## Step 1 — Project setup

```text
[ ] Create frontend
[ ] Create FastAPI backend using uv
[ ] Create PostgreSQL
[ ] Docker Compose
[ ] Environment configuration
```

## Step 2 — Authentication

```text
[ ] Signup
[ ] Login
[ ] JWT
[ ] Password hashing
[ ] Protected APIs
```

## Step 3 — Devices

```text
[ ] ADB service
[ ] GET /devices
[ ] Device selection UI
[ ] Device screenshots
```

## Step 4 — APKs

```text
[ ] APK upload
[ ] APK list
[ ] APK numbering
[ ] APK assignment per device
```

## Step 5 — LLM

```text
[ ] LLM key UI
[ ] Store encrypted key
[ ] Retrieve key internally during execution
```

## Step 6 — Runs

```text
[ ] Create run
[ ] Generate run_id
[ ] Background execution
[ ] Run status
[ ] Polling
[ ] Stop run
[ ] Logs
[ ] Results
```

## Step 7 — Agent

```text
[ ] LangGraph agent
[ ] Connect agent to existing MCP
[ ] Agent → MCP → ADB
[ ] Execute simple scenario
```

## Step 8 — Multi-device

```text
[ ] One agent per selected device
[ ] Device-specific MCP
[ ] Parallel execution
[ ] Aggregate results
```

## Step 9 — UI polish

```text
[ ] Lightweight animations
[ ] Execution screen
[ ] Device screenshots
[ ] Logs
[ ] Status indicators
[ ] Final result
```

## Step 10 — Later

```text
[ ] A2A
[ ] Real-time WebSocket updates
[ ] Recording
[ ] Screenshot intervals
[ ] More LLM providers
[ ] Redis/workers if actually required
```

---

# 30. Important Development Principle

Keep the implementation **simple**.

Do not over-engineer the first version.

The primary working flow should be:

```text
User
 ↓
UI
 ↓
FastAPI
 ↓
Create run_id
 ↓
Selected devices
 ↓
Install assigned APKs
 ↓
Create agents
 ↓
Existing MCP
 ↓
ADB
 ↓
Android devices
 ↓
Results
 ↓
FastAPI
 ↓
UI
```

Once this complete flow works reliably, add advanced features such as A2A, real-time streaming, recording, and distributed workers.

The goal of the first version is not to build a large distributed system. The goal is to prove that **a user can describe an automation scenario and DevAutoFlow can autonomously execute it on one or more real Android devices.**
