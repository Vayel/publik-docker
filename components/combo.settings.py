# To pass env vars to Python scripts run by Publik in services which remove custom env vars:
# https://unix.stackexchange.com/questions/44370/how-to-make-unix-service-see-environment-variables
# So we hardcode the values in the file below when the container starts
import sys
sys.path.insert(0, "/home")
from publik_settings import *

# Databases
# See shared settings
DATABASES['default']['NAME'] = 'combo'
DATABASES['default']['USER'] = 'combo'
DATABASES['default']['PASSWORD'] = DB_COMBO_PASS

# Zone
LANGUAGE_CODE = 'fr-fr'
TIME_ZONE = 'Europe/Paris'

EMAIL_SUBJECT_PREFIX = '[combo] '
