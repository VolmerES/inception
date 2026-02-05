_This project has been created as part of the 42 curriculum by jdelorme._

# Inception

## Description

Inception is a system administration project whose objective is to design, configure, and deploy a secure web infrastructure using Docker and Docker Compose.

The project is executed inside a virtual machine and focuses on service isolation, secure communication, data persistence, and reproducibility. All services are containerized and connected through a private Docker network, with a single entry point exposed to the outside.

The infrastructure includes:

- An NGINX service acting as the only public entry point, configured with TLS.
- A WordPress service running with PHP-FPM only.
- A MariaDB service providing the database backend.
- Docker volumes to persist data.
- A custom Docker network to connect all services internally.

All images are built from custom Dockerfiles, following the constraints defined in the Inception subject.

## Project Overview and Design Choices

This project relies on Docker to provide lightweight virtualization and clear separation of concerns between services. Each component runs in its own container and communicates with others through controlled interfaces.

### Virtual Machines vs Docker

- Virtual Machines emulate a complete operating system, including its own kernel, which leads to higher resource consumption and slower startup times.
- Docker containers share the host kernel and package only the application and its dependencies, resulting in faster startup, reduced overhead, and easier service isolation.

Docker was chosen because it is well suited for service-based architectures and allows fine-grained control over networking, storage, and process management.

### Secrets vs Environment Variables

- Environment variables are used for non-sensitive configuration values such as domain names or service identifiers.
- Docker secrets are used to store sensitive data such as database passwords.

This separation improves security by avoiding hardcoded credentials and prevents sensitive data from being committed to version control.

### Docker Network vs Host Network

- Docker networks allow containers to communicate securely using internal DNS resolution while remaining isolated from the host.
- Host networking removes this isolation and is explicitly forbidden by the project subject.

A dedicated Docker network is used to ensure controlled communication between services without exposing them unnecessarily.

### Docker Volumes vs Bind Mounts

- Docker volumes are managed by Docker and provide a portable and reliable way to persist data.
- Bind mounts depend on host paths and can introduce permission issues and reduce portability.

Docker volumes are used to store the WordPress database and website files, ensuring data persistence across container restarts and rebuilds.

## Instructions

### Requirements

- Docker
- Docker Compose
- Make

### Setup

1. Clone the repository:
   ```bash
   git clone <repository_url>
   cd inception
   ```

### Makefile commands

The project includes a Makefile to automate common tasks:

- **make all**: Alias for `make up`. Builds and starts the application.
- **make up**: Prepares the data directories and launches the containers in detached mode.
- **make mkdir_data**: Creates the required directories for MariaDB and WordPress persistence (`/home/jdelorme/data`).
- **make build**: Builds the Docker images defined in the `docker-compose.yml` file.
- **make down**: Stops and removes the containers, networks, and volumes defined in the compose file.
- **make start**: Starts the containers if they were previously created.
- **make stop**: Stops the running containers without removing them.
- **make restart**: Stops and then restarts the services.
- **make logs**: Displays real-time logs from the running containers.
- **make ps**: Lists the status of the containers managed by the project.
- **make clean**: Stops the containers and removes associated images, volumes, and orphan containers.
- **make fclean**: Performs a full clean (runs `clean`) and additionally removes the local data directory (requires sudo).
- **make re**: Rebuilds the entire application from scratch (runs `fclean` followed by `all`).
