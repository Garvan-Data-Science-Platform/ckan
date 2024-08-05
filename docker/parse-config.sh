#!/bin/bash

cat $1 | sed \
-e "s/{{SECRET_KEY}}/${SECRET_KEY}/g" \
-e "s;{{SITE_URL}};${SITE_URL};g" \
-e "s/{{SESS_KEY}}/${SESS_KEY}/g" \
-e "s/{{DB_PASS}}/${DB_PASS}/g" \
-e "s/{{DB_HOST}}/${DB_HOST}/g" \
-e "s/{{SOLR_HOST}}/${SOLR_HOST}/g" \
-e "s/{{REDIS_HOST}}/${REDIS_HOST}/g" \
-e "s;{{IDP_URL}};${IDP_URL};g" \
-e "s/{{XLOADER_TOKEN}}/${XLOADER_TOKEN}/g" \
-e "s/{{SENDGRID_API_KEY}}/${SENDGRID_API_KEY}/g" \
-e "s/{{SAML_ENTITY}}/${SAML_ENTITY}/g"


#-e "s/{{SECRET_KEY}}/${SECRET_KEY}/g" \
#-e "s/{{SECRET_KEY}}/${SECRET_KEY}/g" \
#-e "s/{{SECRET_KEY}}/${SECRET_KEY}/g"
