from .base import *

DEBUG = True
ALLOWED_HOSTS = ["127.0.0.1"]


# ---- oxylus dev
STATICFILES_FINDERS = [
    "ox.assets.finders.AssetsFinder",
] + STATICFILES_FINDERS

# ---- django-fernet-encrypted-fields
SALT_KEY = ["w]I{!|XWXW&pN^p.PF|D/#=/A^;1)W=<66tvtv/jm{YfF+:ud8ws}9$2HoR,iC)_"]

SECRET_KEY = "c|GAF[xBo}5dD-P`fjEk?Na0D9 5Azp^n[:~Po)lYjJ]>1WfC-D<P|%Jd|&2MWnL"
SECRET_KEY_FALLBACKS = []
