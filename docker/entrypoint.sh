#!/bin/bash

./docker/parse-config.sh docker/ckan.ini.template > /app/ckan.ini && \
    ckan -c /app/ckan.ini db init && \ 
    gunicorn --bind 0.0.0.0:8000 wsgi:application