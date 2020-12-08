# This file is imported in the original settings.py file,
# AFTER /etc/authentic2-multitenant/settings.d/_settings.py

# Databases
DATABASES['default']['NAME'] = 'authentic2_multitenant'
DATABASES['default']['USER'] = 'authentic-multitenant'
DATABASES['default']['PASSWORD'] = PASS_DB_AUTHENTIC

# Zone
LANGUAGE_CODE = 'fr-fr'
TIME_ZONE = 'Europe/Paris'

# Email configuration
EMAIL_SUBJECT_PREFIX = '[authentic] '

# HTTPS Security
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_SECURE = True

# Idp
# SAML 2.0 IDP
#A2_IDP_SAML2_ENABLE = False
# CAS 1.0 / 2.0 IDP
#A2_IDP_CAS_ENABLE = False
# OpenID 1.0 / 2.0 IDP
#A2_IDP_OPENID_ENABLE = False

# Authentifications
#A2_AUTH_PASSWORD_ENABLE = True
#A2_SSLAUTH_ENABLE = False

CACHES = {
    'default': {
       'BACKEND': 'hobo.multitenant.cache.TenantCache',
       'REAL_BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
       'LOCATION': '127.0.0.1:11211',
   }
}

# Role provisionning via local RabbitMQ
HOBO_ROLE_EXPORT = True
