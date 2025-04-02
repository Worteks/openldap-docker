#!/bin/bash

# permission issue
chmod 777 /usr/local/openldap/etc/openldap/slapd.d /usr/local/openldap/var/openldap-data

# import config and data
slapd-cli importldifconfigtemplate
slapd-cli importdatatemplate

# start process
slapd-cli debug start

# tail /dev/null
tail -f /dev/null
