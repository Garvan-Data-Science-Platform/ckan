FROM python:3.10

WORKDIR /app

RUN apt-get update && apt-get install -y xmlsec1

COPY . .

RUN pip install -e . && pip install gunicorn && pip install -r requirements.txt && pip install -r plugins.txt

CMD ./docker/parse-config.sh docker/ckan.ini.template > /app/ckan.ini && \
    ckan -c /app/ckan.ini db init && \ 
    gunicorn --bind 0.0.0.0:8000 wsgi:application