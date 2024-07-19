#!/bin/bash

./docker/parse-config.sh docker/ckan.ini.template > /app/ckan.ini && \
    ckan -c /app/ckan.ini jobs worker