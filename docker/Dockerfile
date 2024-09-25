FROM python:3.10

WORKDIR /app

RUN apt-get update && apt-get install -y xmlsec1

COPY requirements.txt .
COPY plugins.txt .

RUN pip install -r https://raw.githubusercontent.com/ckan/ckanext-xloader/master/requirements.txt && pip install -U requests[security] \
    && pip install gunicorn && pip install -r requirements.txt && pip install -r plugins.txt

RUN pip install -e 'git+https://github.com/ckan/ckanext-pages.git#egg=ckanext-pages'
#RUN pip install -e "git+https://github.com/ckan/ckanext-scheming.git#egg=ckanext-scheming"
COPY ckanext/ckanext-scheming-master /app/ckanext/ckanext-scheming-master
RUN pip install -e /app/ckanext/ckanext-scheming-master
COPY noanonaccess /app/noanonaccess
RUN pip install -e /app/noanonaccess

COPY . .

RUN pip install -e .

CMD echo "Must define a command"