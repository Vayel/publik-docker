# This file is imported in the original settings.py file,
# AFTER /etc/combo/settings.d/_settings.py
# Then it can use the settings defined in "common.py.template"

# Databases
# See shared settings
DATABASES['default']['NAME'] = DB_COMBO
DATABASES['default']['USER'] = USER_DB_COMBO
DATABASES['default']['PASSWORD'] = PASS_DB_COMBO

# Zone
LANGUAGE_CODE = 'fr-fr'
TIME_ZONE = 'Europe/Paris'

EMAIL_SUBJECT_PREFIX = '[combo] '
