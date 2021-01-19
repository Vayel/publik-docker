# This file is imported in the original settings.py file,
# AFTER /etc/fargo/settings.d/_settings.py

# Databases
# See shared settings
DATABASES['default']['NAME'] = 'chrono'
DATABASES['default']['USER'] = 'chrono'
DATABASES['default']['PASSWORD'] = PASS_DB_CHRONO

# Zone
LANGUAGE_CODE = 'fr-fr'
TIME_ZONE = 'Europe/Paris'

EMAIL_SUBJECT_PREFIX = '[chrono] '
