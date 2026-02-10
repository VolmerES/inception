# Developer Documentation (DEV_DOC.md)

This document provides technical details for developers to set up, build, and maintain the Inception project.

## 1. Environment Setup

### Prerequisites

- **Docker**: Ensure Docker Engine is installed and running.
- **Docker Compose**: Required for orchestration (included with modern Docker Desktop/Engine).
- **Make**: Used for executing project commands.
- **Hosts File**: Map the domain to your local machine.

### Configuration

1. **Domain Mapping**:
   Add the following line to your `/etc/hosts` file to redirect the domain to your local loopback address:

   ```
   127.0.0.1 jdelorme.42.fr
   ```

2. **Environment Variables**:
   Configuration is handled in `srcs/.env`. Key variables include:
   - `DOMAIN_NAME`: The domain for NGINX (e.g., `jdelorme.42.fr`).
   - `MYSQL_DATABASE`, `MYSQL_USER`: Database configuration.
   - `WP_TITLE`, `WP_ADMIN_USER`, `WP_ADMIN_EMAIL`: WordPress initialization settings.

3. **Secrets**:
   Ensure the `secrets/` directory contains the required password files (e.g., `db_password.txt`, `wp_admin_password.txt`). These are mounted as Docker secrets.

## 2. Building and Launching

The `Makefile` simplifies Docker Compose operations. Run these commands from the project root:

- **Build and Start (`up`)**:
  Builds images (if needed) and starts containers in detached mode. usage: `make` or `make up`.

- **Build Images Forcefully (`build`)**:
  Rebuilds the Docker images without using the cache:

  ```bash
  make build
  ```

- **Rebuild from Scratch (`re`)**:
  Performs a full clean (removes containers, images, volumes) and restarts:
  ```bash
  make re
  ```

## 3. Managing Containers and Volumes

### Container Management

- **Stop Containers**: `make stop` (halts containers but keeps them).
- **Down**: `make down` (stops and removes containers/networks).
- **Logs**: `make logs` (tails logs for all services).

### Volume Management

- **Clean**: `make clean` (removes containers, images, and networks).
- **Full Clean (`fclean`)**:
  In addition to `clean`, this command **deletes persistent data** on the host.
  ```bash
  make fclean
  ```
  _Warning: This will delete the database files and WordPress content._

## 4. Data Persistence

Data is persisted on the host machine using bind mounts defined in `srcs/docker-compose.yml`.

- **Location**:
  - MariaDB Data: `/home/jdelorme/data/mariadb`
  - WordPress Files: `/home/jdelorme/data/wordpress`

- **Mechanism**:
  Docker volumes `mariadb_data` and `wordpress_data` are mapped to these host directories with the `driver_opts` type `none` and device path. This ensures data survives container restarts and `make down` commands. Data is only removed when running `make fclean` (which executes `sudo rm -rf $(DATA_DIR)`).
