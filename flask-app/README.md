# Flask Tasks App
A simple task management REST API built with Flask and MySQL, containerized with Docker Compose and served behind an Nginx reverse proxy.

## Architecture
```
Client → Nginx (port 80) → Flask app (port 5000) → MySQL (port 3306)
```
- **nginx** — reverse proxy, routes incoming traffic on port 80 to the Flask app
- **flask-app** — REST API for managing tasks
- **mysql** — persistent storage for tasks, data kept in a named Docker volume

## Requirements
- Docker
- Docker Compose

## Setup
1. Clone the repository and move into the project directory.
2. Create a `.env` file in the project root with the following variables:

    ```bash
    # MySQL container init
    MYSQL_ROOT_PASSWORD=your_root_password
    MYSQL_DATABASE=tasksdb
    MYSQL_USER=taskuser
    MYSQL_PASSWORD=your_app_password

    # Flask app DB connection (must match MYSQL_USER/MYSQL_PASSWORD/MYSQL_DATABASE above)
    DB_HOST=mysql
    DB_NAME=tasksdb
    DB_USER=taskuser
    DB_PASSWORD=your_app_password
    ```
    > `.env` is gitignored and should never be committed. Use strong, unique passwords.

3. Start the stack:
    ```bash
    docker compose up -d
    ```
On first run, MySQL initializes the database and user, and the Flask app creates the `tasks` table automatically.

## API
The app is reachable at `http://localhost/` once the stack is running.
### `GET /tasks`
Returns all tasks.
```bash
curl http://localhost/tasks
```
```json
[
  { "id": 1, "title": "buy groceries", "completed": 0 }
]
```
### `POST /tasks`
Creates a new task.
```bash
curl -X POST http://localhost/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "write report"}'
```
```json
{ "message": "Task added successfully" }
```
`title` is required; a missing `title` returns a `400` error.

## Database access
To inspect or modify data directly:
```bash
docker exec -it mysql mysql -u taskuser -p tasksdb
```
Enter `DB_PASSWORD` from your `.env` when prompted.

## Project structure
```
.
├── app.py              # Flask application
├── Dockerfile           # Flask app image
├── docker-compose.yaml  # Service orchestration
├── nginx.conf           # Reverse proxy configuration
├── requirements.txt      # Python dependencies
├── .env                  # Environment variables (not committed)
└── .gitignore
```

## Volumes and networking
### Volume: `mysql_data`
```yaml
volumes:
  mysql_data:/var/lib/mysql
```
- `mysql_data` is a **named Docker volume**, declared under the top-level `volumes:` key in `docker-compose.yaml`.
- It's mounted into the `mysql` container at `/var/lib/mysql`, which is where MySQL stores its actual database files (tables, indexes, InnoDB data).
- Because it's a named volume (not a bind mount to a project folder), Docker manages its physical location on the host, typically:
    ```
    /var/lib/docker/volumes/flask-app_mysql_data/_data
    ```
    (the `flask-app_` prefix comes from the project/folder name Compose uses — check with `docker volume ls` to confirm the exact name on your machine.)
- **This is what makes data persistent.** Stopping and restarting containers (`docker compose down` / `docker compose up`) does not touch this volume, so your tasks survive restarts. Only `docker compose down -v` (or `docker volume rm`) deletes it.
- Inspect it directly:
    ```bash
    docker volume ls
    docker volume inspect flask-app_mysql_data
    ```

### Network: `app-net`
```yaml
networks:
  app-net:
```
- `app-net` is a **user-defined bridge network**, also declared at the top level and referenced by all three services (`mysql`, `nginx`, `flask-app`).
- All containers attached to it can resolve each other by **service name** via Docker's internal DNS — this is why `nginx.conf` reaches Flask at `http://flask-app:5000` and `app.py` reaches MySQL at `DB_HOST=mysql`, without needing IP addresses.
- It isolates this stack's internal traffic from other containers/networks on the host unless they're explicitly attached to `app-net` too.
- Only the ports explicitly published with `ports:` (`80` for nginx, `5000` for flask-app, `3306` for mysql) are reachable from outside Docker, on `localhost`. Everything else stays internal to the network.
- Inspect it:
    ```bash
    docker network ls
    docker network inspect flask-app_app-net
    ```
    This shows exactly which containers are attached and their internal IPs (e.g. the `172.18.0.x` addresses you saw in the Flask startup logs).

## Stopping the app
```bash
docker compose down
```
Add `-v` to also remove the MySQL data volume (this deletes all stored tasks):
```bash
docker compose down -v
```
## Notes
- Nginx proxies to the Flask service by its Docker Compose service name (`flask-app`), not its `container_name`. Keep `nginx.conf`'s `proxy_pass` in sync with the service name if you rename it.
