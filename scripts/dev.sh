#! /usr/bin/env bash

echo $@
CWD=scripts

echo "🌳 Welcome to Oxylus..."
echo

poetry run pip install -e ../oxylus
poetry run pip install -e ../../oxylus-erp
poetry run ox_server/manage.py vue-i18n

export OX_ENV=development
export OX_APP_DIR=./


POETRY_VENV="$(poetry env info -p)"

# Activate it in the current shell
if [ -n "$POETRY_VENV" ]; then
    # shellcheck disable=SC1090
    source "$POETRY_VENV/bin/activate"
else
    echo "Poetry environment not found. Run 'poetry install' first."
    return 1  # if sourced, exit the function
fi

echo $CWD
cat $CWD/logo.txt
