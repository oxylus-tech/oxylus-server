#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Oxylus Entrypoint
# -----------------------------------------------------------------------------
# Handles: virtualenv activation, first-time setup, migrations, assets, and start
# -----------------------------------------------------------------------------

TASK_WORKERS="${TASK_WORKERS:-4}"

OX_APP_DIR="${OX_APP_DIR:-$(dirname "${BASH_SOURCE[0]}")}"
OX_VENV_DIR="${OX_VENV_DIR:-}"
OX_HOST="${OX_HOST:-127.0.0.1}"
OX_PORT="${OX_PORT:-8001}"
OX_DAV_PORT="${OX_DAV_PORT:-8002}"
MANAGE="poetry run $OX_APP_DIR/ox_server/manage.py"

echo "🌳 Welcome to Oxylus..."

#-----------------------------------------------------------------------------
# Activate virtualenv
#-----------------------------------------------------------------------------
if [[ ! -z "$OX_VENV_DIR" ]]; then
    if [[ -d "$OX_VENV_DIR" ]]; then
        echo "📦 Activating existing virtualenv at $OX_VENV_DIR"
        source "$OX_VENV_DIR/bin/activate"
    else
        echo "⚠️  No virtualenv found — creating one with Poetry"
        cd "$OX_APP_DIR"
        poetry config virtualenvs.in-project true
        poetry install --no-dev --no-root
        source "$OX_VENV_DIR/bin/activate"
    fi
fi


#-----------------------------------------------------------------------------
# Start the application
#-----------------------------------------------------------------------------
case "${1:-run}" in
    init)
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
        $MANAGE db_worker # -v$TASK_WORKERS
        ;;
    dev)
        export OX_ENV=development
        echo "🧑‍💻 Running development server..."
        exec $MANAGE runserver $OX_HOST:$OX_PORT
        ;;
    shell)
        exec $MANAGE shell ${@:2:}
        ;;
    bash)
        exec bash
        ;;
    *)
        echo "🔧 Running custom command: $@"
        exec "$@"
        ;;
esac
