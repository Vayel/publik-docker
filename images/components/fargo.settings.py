# This file is imported in the original settings.py file,
# AFTER /etc/fargo/settings.d/_settings.py

# Databases
# See shared settings
DATABASES['default']['NAME'] = 'fargo'
DATABASES['default']['USER'] = 'fargo'
DATABASES['default']['PASSWORD'] = PASS_DB_FARGO

# Zone
LANGUAGE_CODE = 'fr-fr'
TIME_ZONE = 'Europe/Paris'

EMAIL_SUBJECT_PREFIX = '[fargo] '
