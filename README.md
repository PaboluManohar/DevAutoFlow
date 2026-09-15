# DevAutoFlow

DevAutoFlow is a lightweight web platform for AI-driven Android automation. It includes a FastAPI backend, a React + Vite frontend, a PostgreSQL database, and the existing Android MCP server.

## Services

- Frontend: React + Vite + TypeScript
- Backend: FastAPI application
- Database: PostgreSQL
- MCP: Android automation server

## Run the full product with Docker Compose

From the project root:

```bash
cd /home/manohar/Desktop/code/DevAutoFlow
cp .env.example .env
docker compose up --build
```

If you want it in the background:

```bash
docker compose up --build -d
```

To stop everything:

```bash
docker compose down
```

To view logs:

```bash
docker compose logs -f
```

Open the app once the containers are running:

- Frontend: http://localhost:5050
- Backend API: http://localhost:5051/docs
- MCP endpoint: http://localhost:5052/mcp
- PostgreSQL: localhost:5053

> The project uses the compose file in this repo to start the database, backend, frontend, and MCP service together on the 5050-5053 port range.

## Local development without Docker

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

The backend discovers MCP tools with `langchain-mcp-adapters` and passes them into the LangGraph device-agent node.

## Environment notes

- The backend expects PostgreSQL and the MCP service to be available.
- The MCP service uses host networking and reaches the host Android ADB server through `127.0.0.1:5037`.
- On Linux, start ADB before Compose:

  ```bash
  adb kill-server
  adb -a start-server
  adb devices
  ```

  Host networking lets the MCP container use the host network namespace directly.

## Default credentials

- Database user: `devautoflow`
- Database password: `devautoflow`
- JWT secret: `change-me-in-production`
- MCP auth: `devautoflow-secret`

## Useful commands

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

This starter structure is intentionally simple and keeps the product easy to run locally while matching the architecture described in the implementation document.
