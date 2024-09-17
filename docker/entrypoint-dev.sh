#!/bin/bash

./docker/parse-config.sh docker/ckan-dev.ini.template > /app/ckan.ini && \
    ckan -c /app/ckan.ini db init && \ 
    ckan -c /app/ckan.ini db upgrade -p pages && \
    gunicorn --bind 0.0.0.0:8000 --workers=2 --threads=2 wsgi:application