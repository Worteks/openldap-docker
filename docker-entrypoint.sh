#!/bin/bash

# Copy files
mv /usr/local/openldap/* /openldap/

# Link directories
ln -s /openldap/* /usr/local/openldap/

# import config and data
slapd-cli importldifconfigtemplate
slapd-cli importdatatemplate

# start process
slapd-cli start

# tail /dev/null
tail -f /dev/null
