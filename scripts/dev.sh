#! /usr/bin/env bash

echo $@
CWD=scripts

echo "🌳 Welcome to Oxylus..."
echo

POETRY_VENV="$(poetry env info -p)"
SITE_PACKAGE=$POETRY_VENV/lib/python3.13/site-packages

VENV_OX="$SITE_PACKAGE/ox"
VENV_OXERP="$SITE_PACKAGE/ox_erp"
if [[ ! -L $PWD/ox ]]; then
    rm $VENV_OX $VENV_OXERP -rf
    ln -s `dirname $PWD`/oxylus/ox $PWD/ox
    ln -s `dirname $PWD`/oxylus-erp/ox_erp $PWD/ox_erp
fi


export OX_ENV=development
export OX_APP_DIR=./


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
