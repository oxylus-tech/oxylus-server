"""Django settings for ox.

For more information on this file, see
https://docs.djangoproject.com/en/5.0/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/5.0/ref/settings/
"""

import os
import sys
from pathlib import Path

from dynaconf import Dynaconf

BASE_DIR = os.environ.get("OX_APP_DIR")
BASE_DIR = BASE_DIR and Path(BASE_DIR)
OX_DIR = Path(__file__).resolve().parent.parent


# ---- Dynaconf
ENV = os.environ.get("OX_ENV", "production")

if ENV == "production":
    BASE_DIR = BASE_DIR or Path("/srv/oxylus")
    SETTINGS_DIR = Path("/etc/oxylus")
    DEBUG = False
else:
    BASE_DIR = BASE_DIR or Path(__file__).resolve().parent.parent.parent
    SETTINGS_DIR = Path(BASE_DIR / "conf")


OX = {"SETTINGS_DIR": SETTINGS_DIR}

settings = Dynaconf(
    environments=True,
    # We provide defaults
    settings_file=[Path(__file__).resolve().parent / "default.yaml", OX["SETTINGS_DIR"] / "plugins.yaml"],
    includes=[
        OX["SETTINGS_DIR"] / "*",
        OX["SETTINGS_DIR"] / ".*",
        OX["SETTINGS_DIR"] / "tmp" / "*",
        # "/etc/oxylus/apps/*",
        "/etc/oxylus/*.yaml",
        "/etc/oxylus/.*.yaml",
    ],
    envvar_prefix="OX",
    merge_enabled=True,
    ENVVAR_PREFIX_FOR_DYNACONF="OX",
    ENV_SWITCHER_FOR_DYNACONF="OX_ENV",
    BASE_DIR=BASE_DIR,
    OX=OX,
)

globals().update(settings.as_dict())


BASE_DIR = Path(BASE_DIR)

if plugins := getattr(settings, "PLUGINS_APPS", None):
    plugins = [p for p in plugins.keys() if p not in INSTALLED_APPS]
    INSTALLED_APPS = plugins + INSTALLED_APPS

# ---- Forced values
ROOT_URLCONF = "ox_server.urls"
WSGI_APPLICATION = os.environ.get("OX_WSGI_APPLICATION") or "ox_server.wsgi.application"
ASGI_APPLICATION = os.environ.get("OX_ASGI_APPLICATION") or "ox_server.asgi.application"

USE_I18N = True
USE_L10N = True
USE_TZ = True
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

STATICFILES_FINDERS = list(set(STATICFILES_FINDERS))

# Note: we use a generic name to be agnostic with frontend applications
LANGUAGE_COOKIE_NAME = "lang"

TASKS = {"default": {"BACKEND": "django_tasks.backends.database.DatabaseBackend"}}


# ---- Oxylus
if settings_dir := OX.get("SETTINGS_DIR"):
    OX["SETTINGS_DIR"] = Path(settings_dir)
else:
    OX["SETTINGS_DIR"] = BASE_DIR / "conf"
