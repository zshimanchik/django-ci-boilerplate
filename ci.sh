#!/usr/bin/env bash

set -e

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd ${BASEDIR} > /dev/null

# fixme project name
PROJECT_NAME='my-project'
PROJECT_VERSION=$(git describe --tag)
USER_ID=$(id -u)
HTTP_CLIENT='curl'

function release() {
    echo "releasing..."
    build
    push_images
    notify "${PROJECT_NAME}: *${PROJECT_VERSION}* pushed to registry"
}

function build() {
    echo "building..."
    echo PROJECT_VERSION=${PROJECT_VERSION} > .env
    cp .env backend/build_info.ini
    build_backend

    prepare_nginx
    docker-compose build
    restore_nginx
}

function build_backend() {
    echo "building backend..."
    mkdir -p log
    mkdir -p media
    docker-compose build backend
    ./dmanage.sh collectstatic --noinput
}

function prepare_nginx() {
    echo "preparing nginx..."
    mv nginx/static nginx/static_backup
    cp -r backend/static nginx/static
}

function restore_nginx() {
    echo "restoring nginx..."
    rm -rf nginx/static
    mv nginx/static_backup nginx/static
}

function push_images() {
    echo "pushing images..."
    docker-compose push
}

function notify() {
    if [ ! -z "${TELEGRAM_TOKEN}" ] && [ ! -z "${TELEGRAM_CHAT_ID}" ]; then
        ${HTTP_CLIENT} "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage?parse_mode=markdown&chat_id=${TELEGRAM_CHAT_ID}&text=${1}"
    else
        echo WARNING TELEGRAM_TOKEN or TELEGRAM_CHAT_ID is missing. notification ignored.
    fi
}

function deploy() {
    if [ -z "$1" ]; then
        echo "usage $0 deploy username@hostname"
        exit 1
    fi
    ssh $1 ./${PROJECT_NAME}/deploy.sh ${PROJECT_VERSION} \
        && notify "${PROJECT_NAME}: *${PROJECT_VERSION}* deployed on $1 successfully" \
        || ( notify "${PROJECT_NAME}: *${PROJECT_VERSION}* cannot be deployed on $1" && exit 1 )
}

function usage() {
    echo "usage: $0 [ build | release | deploy ]"
}

if [ -z "$1" ]; then
    usage
else
    $@
fi

popd > /dev/null
