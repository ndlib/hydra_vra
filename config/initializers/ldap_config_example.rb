# connection settings
LDAP_HOST = 'directory.nd.edu'
LDAP_BASE = 'o=University of Notre Dame,st=Indiana,c=US'
LDAP_PORT = 389

LDAP_ACCESS_METHOD   = :simple
LDAP_ACCESS_USER     = ''
LDAP_ACCESS_PASSWORD = 'anonymous'

# the name of your institution
LDAP_INSTITUTION = 'University of Notre Dame'

# specific ldap field names
LDAP_USER_ID        = 'uid'
LDAP_FIRST_NAME     = 'givenname'
LDAP_LAST_NAME      = 'sn'
LDAP_NICKNAME       = 'ndvanityname'
LDAP_AGGREGATE_NAME = 'cn'
LDAP_PREFERRED_NAME = 'ndvanityname'
LDAP_DEPARTMENT     = 'ndprimaryaffiliation'
LDAP_PHOTO          = ''
