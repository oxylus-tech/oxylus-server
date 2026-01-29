#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Oxylus Entrypoint
# -----------------------------------------------------------------------------
# Handles: virtualenv activation, first-time setup, migrations, assets, and start
# -----------------------------------------------------------------------------
echo "🌳 Welcome to Oxylus..."

var=$(printf '\033[32m')
env=$(printf '\033[33m')
reset=$(printf '\033[0m')

if [[ $# -eq 0 || "$1" == "help" ]]; then
    echo "This helper script provides different command to run oxylus applications: "
    echo
    echo "Commands:"
    echo "- $var setup$reset: initialize Oxylus, databases, etc."
    echo "- $var server$reset: run production server using gunicorn."
    echo "- $var dav$reset: run WebDav server using gunicorn."
    echo "- $var tasks$reset: run backend task scheduler."
    echo "- $var dev$reset: run development server (activating dev environment settings)."
    echo "- $var manage$reset: run this instance's django 'manage.py'."
    echo "- $var ox$reset: run 'ox' manage command."
    echo "- $var shell$reset: run 'shell' manage command"
    echo
    echo "Environment variables:"
    echo "- $env OX_APP_DIR$reset: current oxylus server directory;"
    echo "- $env OX_HOST$reset: web and webdav server host name;"
    echo "- $env OX_PORT$reset: web server port;"
    echo "- $env OX_DAV_PORT$reset: WebDav server port;"
    echo "- $env TASK_WORKERS$reset: number of current workers of backend tasks;"
    exit;
fi


TASK_WORKERS="${TASK_WORKERS:-4}"

OX_APP_DIR="${OX_APP_DIR:-$(dirname "${BASH_SOURCE[0]}")}"
OX_HOST="${OX_HOST:-127.0.0.1}"
OX_PORT="${OX_PORT:-8001}"
OX_DAV_PORT="${OX_DAV_PORT:-8002}"
MANAGE="poetry run $OX_APP_DIR/ox_server/manage.py"

POETRY_VENV="$(poetry env info -p)"


#-----------------------------------------------------------------------------
# Activate virtualenv
#-----------------------------------------------------------------------------
if [[ ! -z "$POETRY_VENV" ]]; then
    if [[ -d "$POETRY_VENV" ]]; then
        echo "📦 Activating existing virtualenv at $POETRY_VENV"
        source "$POETRY_VENV/bin/activate"
    else
        echo "⚠️  No virtualenv found — creating one with Poetry"
        cd "$OX_APP_DIR"
        poetry config virtualenvs.in-project true
        poetry install --no-root
        source "$POETRY_VENV/bin/activate"
    fi
fi


#-----------------------------------------------------------------------------
# Start the application
#-----------------------------------------------------------------------------
case "${1}" in
    setup)
        echo "⚙️ Setup project configuration..."
        $MANAGE migrate
        $MANAGE ox setup --default-admin
        ;;
    server)
        echo "🚀 Starting the production server..."
        exec gunicorn ox_server.wsgi:application \
                --bind 0.0.0.0:${OX_PORT} \
                --workers "${GUNICORN_WORKERS:-3}" \
                --timeout 120
                # --log-level debug --capture-output
        ;;
    dav)
        echo "☁️ Starting the WebDAV server..."
        exec gunicorn ox.apps.files.dav:application \
                --bind 0.0.0.0:${OX_DAV_PORT} \
                --workers "${GUNICORN_WORKERS:-3}" \
                --timeout 120
        ;;
    tasks)
        echo "🪓 Start tasks scheduler with $TASK_WORKERS workers"
        $MANAGE db_worker ${@:2} # -v$TASK_WORKERS
        ;;
    dev)
        export OX_ENV=development
        echo "🧑‍💻 Running development server..."
        cat $OX_APP_DIR/scripts/logo.txt
        exec $MANAGE runserver $OX_HOST:$OX_PORT
        ;;
    manage)
        cat $OX_APP_DIR/scripts/logo.txt
        exec $MANAGE ${@:2}
        ;;
    ox)
        cat $OX_APP_DIR/scripts/logo.txt
        exec $MANAGE ox ${@:2}
        ;;
    shell)
        cat $OX_APP_DIR/scripts/logo.txt
        exec $MANAGE shell ${@:2}
        ;;
    *)
        echo "🔧 Running custom command: $@"
        exec "$@"
        ;;
esac
