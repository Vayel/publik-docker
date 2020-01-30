# To pass env vars to Python scripts run by Publik in services which remove custom env vars:
# https://unix.stackexchange.com/questions/44370/how-to-make-unix-service-see-environment-variables
# So we hardcode the values in the file below when the container starts
import sys
sys.path.insert(0, "/home")
from publik_settings import *

# Databases
# w.c.s. doesn't use Django ORM (yet) so do not declare any database for now.
#DATABASES['default']['NAME'] = 'wcs'
#DATABASES['default']['USER'] = 'wcs'
#DATABASES['default']['PASSWORD'] = DB_WCS_PASS

# Override shared settings
DATABASES = {}

# Zone
LANGUAGE_CODE = 'fr-fr'
TIME_ZONE = 'Europe/Paris'

EMAIL_SUBJECT_PREFIX = '[wcs] '

# HTTPS Security
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_SECURE = True
