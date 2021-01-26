# This file is imported in the original settings.py file,
# AFTER /etc/wcs/settings.d/_settings.py
# Then it can use the settings defined in "common.py.template"

# Databases
# w.c.s. doesn't use Django ORM (yet) so do not declare any database for now.
# Override shared settings
DATABASES = {}

# Zone
LANGUAGE_CODE = 'fr-fr'
TIME_ZONE = 'Europe/Paris'

EMAIL_SUBJECT_PREFIX = '[wcs] '

# HTTPS Security
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_SECURE = True
