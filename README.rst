Oxylus Server
=============

Overview
--------

``oxylus-server`` provides the server runtime and instance management for the Oxylus framework. It is a Django-based project that handles the core backend, task scheduling, WebDAV services, and Docker deployment. This repository also ships a Docker image and related runtime configuration.

The server comes with dependencies to:

- `oxylus <https://github.com/oxylus-tech/oxylus/>`_ : the core framework and libraries.
- `oxylus-erp <https://github.com/oxylus-tech/oxylus/>`_ : ERP application built on Oxylus.

Future releases will include an improved application installation system.


**Important note**: the current installation process is still under development. However building the Dockerfile and running it should be ok. We'll provide it soonish.


Directory Structure
-------------------

- ``ox_server/`` – Python package for the server (``oxylus-server``).
- ``scripts/`` – helper scripts for setup, development, and runtime tasks.
- ``static/`` – collected Django static files.
- ``conf/`` – development and test configuration files.

Configuration
-------------

Oxylus uses **Dynaconf** for configuration management.

Environments:

- **development**: SQLite database, ``DEBUG=True``.
- **production**: PostgreSQL database, ``DEBUG=False``.
- **test**: for running automated tests.

Configuration Directories:

- ``/etc/oxylus`` – production mode.
- ``./conf`` – development and test environments.

Secrets such as ``SECRET_KEY`` and encryption keys are stored in ``secrets.yaml``. Generate or update them using:

.. code-block:: bash

   ./run.sh setup
   ./run.sh ox update-secrets
   ./run.sh ox install ox_erp.locations ox_erp.contacts ox_erp.contacts_mails

Quickstart
----------

Requirements:

- Python 3
- Poetry
- Postgresql (for production)
- Nginx (for production)

Installation:

.. code-block:: bash

   git clone https://github.com/oxylus-tech/oxylus-server/
   cd oxylus-server
   poetry install
   poetry update
   ./run.sh setup

Usage
-----

``run.sh`` is the primary entrypoint for all server operations. You can find more with ``./run.sh help``.
It wraps Django's ``manage.py`` and provides multiple commands to setup, run, and manage the server.

+---------+--------------------------------------------------------------+
| Command | Description                                                  |
+=========+==============================================================+
| setup   | Initialize Oxylus, database, and environment.               |
+---------+--------------------------------------------------------------+
| server  | Run production server using Gunicorn.                        |
+---------+--------------------------------------------------------------+
| dav     | Run WebDav server using Gunicorn.                             |
+---------+--------------------------------------------------------------+
| tasks   | Run backend task scheduler.                                   |
+---------+--------------------------------------------------------------+
| dev     | Run development server with dev settings.                    |
+---------+--------------------------------------------------------------+
| manage  | Run this instance's Django `manage.py`.                      |
+---------+--------------------------------------------------------------+
| ox      | Run Oxylus-specific management commands.                     |
+---------+--------------------------------------------------------------+
| shell   | Open Django shell.                                            |
+---------+--------------------------------------------------------------+

Environment Variables:

- ``OX_APP_DIR`` – path to the Oxylus server directory.
- ``OX_HOST`` – web and WebDav server hostname.
- ``OX_PORT`` – web server port.
- ``OX_DAV_PORT`` – WebDav server port.
- ``TASK_WORKERS`` – number of backend task workers.

Development
-----------

Assumes these directories exist alongside each other:

.. code-block:: text

   oxylus-server/  oxylus/  oxylus-erp/

Initialize the development environment:

.. code-block:: bash

   source scripts/dev.sh

This script will:

- Install `oxylus` and `oxylus-erp` from relative paths.
- Collect Vue i18n translations.
- Initialize default environment variables.
- Set `OX_ENV=development`.
- Activate Poetry environment.

Run the development server:

.. code-block:: bash

   ./run.sh dev

Production
----------

Docker
......

Build and run using the provided `runtime.Dockerfile` and `docker-compose.yaml`. Services included:

- **oxylus** – main server (Gunicorn, port 8001)
- **oxylus-dav** – WebDav server (Gunicorn, port 8002)
- **oxylus-setup** – ensures server is initialized
- **nginx** – reverse proxy, configuration in ``scripts/conf/nginx.conf``
- **db** – PostgreSQL database

By default, ports 8001 and 8002 are exposed for web and WebDav.

Custom Production
.................

If not using Docker, you must provide:

- Nginx reverse proxy.
- PostgreSQL database

Then run the services needed (web server, tasks scheduler, WebDav, etc.) using:

.. code-block:: bash

   ./run.sh server
   ./run.sh tasks
   ./run.sh dav
