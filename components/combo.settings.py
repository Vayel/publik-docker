# This file is imported in the original settings.py file,
# AFTER /etc/combo/settings.d/_settings.py

# Databases
# See shared settings
DATABASES['default']['NAME'] = 'combo'
DATABASES['default']['USER'] = 'combo'
DATABASES['default']['PASSWORD'] = DB_COMBO_PASS

# Zone
LANGUAGE_CODE = 'fr-fr'
TIME_ZONE = 'Europe/Paris'

EMAIL_SUBJECT_PREFIX = '[combo] '
