FROM --platform=linux/amd64 python:3.10

WORKDIR /app

RUN apt-get update && apt-get install -y xmlsec1

COPY requirements.txt .
COPY plugins.txt .

RUN pip install -r https://raw.githubusercontent.com/ckan/ckanext-xloader/master/requirements.txt && pip install -U requests[security] \
    && pip install gunicorn && pip install -r requirements.txt && pip install -r plugins.txt

COPY . .

RUN pip install -e .

CMD echo "Must define a command"