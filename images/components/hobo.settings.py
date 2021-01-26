# This file is imported in the original settings.py file,
# AFTER /etc/hobo/settings.d/_settings.py
# Then it can use the settings defined in "common.py.template"

# Databases
# See shared settings
DATABASES['default']['NAME'] = 'hobo'
DATABASES['default']['USER'] = 'hobo'
DATABASES['default']['PASSWORD'] = PASS_DB_HOBO

LANGUAGE_CODE = 'fr-fr'
TIME_ZONE = 'Europe/Paris'

EMAIL_SUBJECT_PREFIX = '[hobo] '
