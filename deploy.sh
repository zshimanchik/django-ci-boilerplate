#!/usr/bin/env bash
BACKUP_DIR=backup

set -e

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd ${BASEDIR} > /dev/null

echo "backup..."
mkdir -p ${BACKUP_DIR}
./dmanage.sh mkbackup | gzip  -vc > "${BACKUP_DIR}/dump-$(date -Iseconds).json.gz"


# deploy specific version, if it was specified
# e.g. `./deploy 0.4`
if [ ! -z $1 ]
then
    echo "PROJECT_VERSION=$1" > .env
fi

#echo "pulling docker images..."
docker-compose -f docker-compose.prod.yml pull

echo "stopping db dependent services..."
docker-compose -f docker-compose.prod.yml stop backend

echo "migrating..."
./dmanage.sh migrate

echo "raising and recreating services..."
docker-compose -f docker-compose.prod.yml up -d --force-recreate

popd > /dev/null
