# This file is imported in the original settings.py file,
# AFTER /etc/passerelle/settings.d/_settings.py

# Databases
# See shared settings
DATABASES['default']['NAME'] = 'passerelle'
DATABASES['default']['USER'] = 'passerelle'
DATABASES['default']['PASSWORD'] = DB_PASSERELLE_PASS

# Zone
LANGUAGE_CODE = 'fr-fr'
TIME_ZONE = 'Europe/Paris'

EMAIL_SUBJECT_PREFIX = '[passerelle] '
