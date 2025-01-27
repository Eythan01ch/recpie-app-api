# PYTHON IMAGE FROM DOCKERHUB
FROM python:3.9-alpine3.13
# maintainer (INFO NOT REQUIRED)
LABEL maintainer='eythan.cdev@gmail.com'
# FOR NO DELAYS OF LOGS IN THE CONSOLE
ENV PYTHONUNBUFFER 1

# GETTING THE REQUIREMENTS ON THE IMAGE
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./scripts /scripts
# GETTING THE APP ITSELF
COPY ./app /app
# SETTING THE WORK DIRECTORY
WORKDIR /app
# ENABLING ACCESS TO PORT 8000
EXPOSE 8000


# new virtualenv
ARG DEV=false
RUN python -m venv /py && \
#   upgrading pip
    /py/bin/pip install --upgrade pip && \
#   config our image to work with psycopg with dependencies cleanup
    apk add --update --no-cache postgresql-client jpeg-dev && \
    apk add --update --no-cache --virtual .tmp-build-deps  \
        build-base postgresql-dev musl-dev zlib zlib-dev linux-headers &&\
#   installing the requirements
    /py/bin/pip install -r /tmp/requirements.txt && \
#   if in development then installs dev packages
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
#   deleting the tmp dir (requirements) everything that is not needed, should be deleted
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
#   adding a user to the image, for not using the root user. SECURITY
    adduser \
        --disabled-password \
#    not needing a home dir
        --no-create-home \
#    name of the user
        django-user && \
    mkdir -p /vol/web/media &&\
    mkdir -p /vol/web/static &&\
    chown -R django-user:django-user /vol && \
    chmod -R 755 /vol && \
    chmod -R +x /scripts


# sepsefication of the venv
ENV PATH="/scripts:/py/bin:$PATH"
# switching to the django-user
USER django-user

CMD ["run.sh"]
