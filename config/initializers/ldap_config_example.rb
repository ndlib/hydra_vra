# NOTE change these settings for your institution and rename the file to ldap_config.rb
# If you wish to add ldap_config.rb to source control edit the .gitingore file

# connection settings
LDAP_HOST = "ldap.virginia.edu"
LDAP_BASE = "o=University of Virginia,c=US"
LDAP_PORT = 389

LDAP_ACCESS_METHOD   = :simple
LDAP_ACCESS_USER     = ""
LDAP_ACCESS_PASSWORD = ""

# the name of your institution
LDAP_INSTITUTION = ""

# specific ldap field names
LDAP_USER_ID        = "userid"
LDAP_FIRST_NAME     = "givenname"
LDAP_LAST_NAME      = "sn"
LDAP_AGGREGATE_NAME = ""
LDAP_PREFERRED_NAME = ""
LDAP_COMPUTING_ID   = "uid"
LDAP_DEPARTMENT     = "department"
LDAP_PHOTO          = "jpegphoto"

