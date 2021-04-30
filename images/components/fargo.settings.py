# This file is imported in the original settings.py file,
# AFTER /etc/fargo/settings.d/_settings.py
# Then it can use the settings defined in "common.py.template"

# Databases
# See shared settings
DATABASES['default']['NAME'] = DB_FARGO
DATABASES['default']['USER'] = USER_DB_FARGO
DATABASES['default']['PASSWORD'] = PASS_DB_FARGO

# Zone
LANGUAGE_CODE = 'fr-fr'
TIME_ZONE = 'Europe/Paris'

EMAIL_SUBJECT_PREFIX = '[fargo] '
