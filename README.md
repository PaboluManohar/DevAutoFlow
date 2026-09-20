# DevAutoFlow

DevAutoFlow is a lightweight web platform for AI-powered Android automation. The project combines a FastAPI backend, a React and Vite frontend, a PostgreSQL database, and the existing Android MCP server.

## Services

- **Frontend:** React, Vite, and TypeScript
- **Backend:** FastAPI
- **Database:** PostgreSQL
- **MCP server:** Android automation service

## Run the full stack with Docker Compose

Run the following commands from the project root:

```bash
cd /home/manohar/Desktop/code/DevAutoFlow
cp .env.example .env
docker compose up --build
```

To run the services in the background:

```bash
docker compose up --build -d
```

To stop all services:

```bash
docker compose down
```

To follow the service logs:

```bash
docker compose logs -f
```

Once the containers are running, access the services at:

- Frontend: http://localhost:5050
- Backend API: http://localhost:5051/docs
- MCP endpoint: http://localhost:5052/mcp
- PostgreSQL: localhost:5053

> Docker Compose starts the database, backend, frontend, and MCP services together. The services use ports 5050 through 5053.

## Run locally without Docker

### Backend

```bash
cd DevAutoFlow-Backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

### Frontend

```bash
cd DevAutoFlow-UI
npm install
npm run dev -- --host 0.0.0.0
```

### MCP server

```bash
cd DevAutoFlow-MCP
npm install
npm run build
node lib/index.js --listen 0.0.0.0:5052
```

The backend discovers MCP tools through `langchain-mcp-adapters` and makes them available to the LangGraph device-agent node.

## Environment requirements

- The backend requires PostgreSQL and the MCP service to be running.
- The MCP service uses host networking to connect to the host Android ADB server at `127.0.0.1:5037`.
- On Linux, start ADB before launching Docker Compose:

  ```bash
  adb kill-server
  adb -a start-server
  adb devices
  ```

  Host networking allows the MCP container to use the host network namespace directly.

## Default configuration

- Database user: `devautoflow`
- Database password: `devautoflow`
- JWT secret: `change-me-in-production`
- MCP auth: `devautoflow-secret`

## Common commands

```bash
# View running containers
docker compose ps

# View logs
docker compose logs -f backend frontend mcp db

# Stop everything
docker compose down

# Reset database volume
docker compose down -v
```

## Architecture

```text
Browser
  -> Frontend UI
  -> FastAPI backend
  -> PostgreSQL
  -> Android MCP server
  -> ADB / Android devices
```

This starter structure is intentionally simple, making the product easy to run locally while following the architecture described in the implementation document.
