#!/usr/bin/env bash

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd ${BASEDIR} > /dev/null

DOCKER_COMPOSE=/usr/local/bin/docker-compose
USER_ID=$(id -u)

if [ -f docker-compose.yml ]
then
    docker_compose_file="docker-compose.yml"
else
    docker_compose_file="docker-compose.prod.yml"
fi

case $1 in
    shell|migrate|makemigrations|createsuperuser|dumpdata|loaddata|collectstatic)
        command="python manage.py $@"
        ;;
    version)
        command="cat build_info.ini"
        ;;
    mkbackup)
        command="python manage.py dumpdata --natural-primary --natural-foreign"
        ;;
    *)
        USER_ID=0
        command="$@"
        ;;
esac

${DOCKER_COMPOSE} -f ${docker_compose_file} run --user=${USER_ID} --rm --no-deps backend ${command}

popd > /dev/null
