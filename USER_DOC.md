# User Documentation (USER_DOC.md)

This document explains how to use and manage the Inception project stack.

## 1. Services Provided

This project deploys a LEMP-like stack (Linux, NGINX, MariaDB, PHP-FPM/WordPress) using Docker containers. The services include:

- **NGINX**: A web server that handles HTTPS requests and serves the WordPress site.
- **WordPress**: The content management system for the website.
- **MariaDB**: The database management system storing WordPress data.

## 2. Starting and Stopping the Project

The project is managed via a `Makefile` at the root of the repository.

- **Start Services**:
  Run the following command to build and start the containers in the background:

  ```bash
  make up
  ```

  This will also create the necessary data directories if they don't exist.

- **Stop Services**:
  To stop the running containers:

  ```bash
  make stop
  ```

- **Restart Services**:
  To restart the containers:
  ```bash
  make restart
  ```

## 3. Accessing the Website and Administration Panel

Once the services are running, you can access the application through your web browser.

- **Website URL**: https://jdelorme.42.fr
  _Note: You may need to accept a self-signed certificate warning due to the local TLS configuration._

- **Administration Panel**: https://jdelorme.42.fr/wp-admin
  - Use the credentials found in the secrets files (see below) or the environment configuration.

## 4. Locating and Managing Credentials

Sensitive information such as passwords and usernames are stored in the `secrets/` directory at the project root.

Files include:

- `secrets/db_root_password.txt`: Root password for MariaDB.
- `secrets/db_password.txt`: Password for the WordPress database user.
- `secrets/wp_admin_password.txt` (or similar): Admin password for WordPress.
- `secrets/wp_user_password.txt`: Standard user password for WordPress.

_Ensure these files are kept secure and not shared publicly._

## 5. Checking Service Status

To verify that all services are running correctly:

1. **Check Container Status**:
   Run the following command to list active containers:

   ```bash
   make ps
   ```

   You should see `nginx`, `wordpress`, and `mariadb` with a status of "Up".

2. **View Logs**:
   To see the logs of all services in real-time:
   ```bash
   make logs
   ```
   Press `Ctrl+C` to exit the log view.
