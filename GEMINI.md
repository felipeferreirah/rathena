# rAthena Project Analysis

## Project Overview

This project is **rAthena**, a collaborative, open-source software development project focused on creating a robust and versatile Massively Multiplayer Online Role-Playing Game (MMORPG) server package. It is a continuation of the eAthena project.

*   **Language:** C++ (C++17 standard)
*   **Build Systems:** The project supports multiple build systems:
    *   **CMake:** The primary and recommended build system.
    *   **GNU Autotools:** For Linux/macOS systems (`configure`, `make`).
    *   **Visual Studio:** A `.sln` file is provided for Windows users.
*   **Dependencies:**
    *   MySQL 5+ or MariaDB 5+
    *   pthreads, zlib, and other common libraries.
*   **Platforms:** Windows, Linux, macOS.
*   **Architecture:** The server is composed of three main services:
    *   `login-server`: Handles player authentication.
    *   `char-server`: Manages character data.
    *   `map-server`: Controls the game world, NPCs, and gameplay.
    *   An optional `web-server` is also available.

## Building and Running

### Building

The recommended way to build the project is using **CMake**.

**General CMake Build Process:**

1.  Create a build directory: `mkdir build`
2.  Navigate into the build directory: `cd build`
3.  Run CMake to configure the project: `cmake ..`
    *   You can use various `-D` flags to configure the build (see `CMakeLists.txt` for details). For example, `-DPACKETVER=...` to set a specific client version.
4.  Compile the project: `make` (or `nmake`/`msbuild` on Windows).

For platform-specific instructions, refer to the [official documentation](https://github.com/rathena/rathena/wiki).

### Running the Server

The server can be started using the provided shell scripts:

*   **Linux/macOS:** Use the `./start-server.sh` script:
    *   `./start-server.sh start`: Starts all servers.
    *   `./start-server.sh stop`: Stops all servers.
    *   `./start-server.sh restart`: Restarts all servers.
    *   `./start-server.sh status`: Shows the status of all servers.
    *   `./start-server.sh monitor`: Monitors the servers in real-time.
    *   `./start-server.sh autorestart`: Automatically restarts crashed servers.
    *   `./start-server.sh tail`: Tails the server logs.
*   **Windows:** Use the `athena-start` batch script.

The server executables (`login-server`, `char-server`, `map-server`) will be generated in the root directory of the project.

## Development Conventions

### Code Style

*   The project is written in C++17.
*   The code follows a consistent style, with clear and descriptive naming for variables and functions.
*   Namespaces are used to organize the code (e.g., `rathena`).
*   Header files use `.hpp` extension.
*   The code is well-commented, with explanations for complex logic.

### Configuration

*   Server configuration is done through `.conf` files located in the `conf` directory.
*   The configuration files use a simple `key: value` format.
*   The battle logic is configured in `conf/battle/`.
*   Other server settings are in `conf/char_athena.conf`, `conf/login_athena.conf`, and `conf/map_athena.conf`.

### NPC Scripting

*   NPCs are scripted using a custom scripting language in `.txt` files located in the `npc` directory.
*   The main script loading configuration is `npc/scripts_athena.conf`.
*   The scripting language is simple and includes commands for displaying messages, handling player choices, giving items, and more.

### Database

*   The server uses a MySQL or MariaDB database.
*   Database schema and initial data are located in the `sql-files` directory.
*   Game data, such as items, mobs, and skills, are stored in YAML files (`.yml`) in the `db` directory.

### Contribution

*   Contributions are welcome via pull requests on GitHub.
*   Bug reports and feature requests should be submitted to the GitHub issue tracker.
*   Detailed contribution guidelines are available in `.github/CONTRIBUTING.md`.
