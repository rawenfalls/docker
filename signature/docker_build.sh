#!/bin/bash

# флаг запуска контейнера после сборки
long=false
# флаг возвращения к дефолтным настройкам
default=false

CONTAINER_NAME="signvault"
TIME_TO_SLEEP=10

while [ "$#" -gt 0 ]; do
    case "$1" in
        -l|--long)
            long=true
            shift
            ;;
        -d|--default)
            default=true
            shift
            ;;
    esac
done

cd /
if [ "$default" = true ]; then
    # запускаем демон докер если он не запущен и паралельно ждем "$TIME_TO_SLEEP" секунд, для полного запуска
    dockerd & sleep "$TIME_TO_SLEEP"
    # останавливаем все докер контейнеры
    docker container stop $(docker container ls -q)
    # удаляем все докер контейнеры
    docker rm $(docker ps -a -q)
    # загружаем образ vault контейнера для запуска
    docker load -i "$CONTAINER_NAME".tar && sleep "$TIME_TO_SLEEP"
    # запускаем контейнер vault
    docker run -p 8200:8200 --name "$CONTAINER_NAME" --rm -d signvault & sleep "$TIME_TO_SLEEP"
    # распечатываем базу данных внутри vault
    docker exec "$CONTAINER_NAME" ./start.sh & sleep "$TIME_TO_SLEEP"
fi
# извлекаем пароль из базы данных в файл
if [ "$long" = true ]; then
# Сборка с ключем 256 или 512
    ./extraction_vault $(docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$CONTAINER_NAME") 8200 password password512 > /builds/bmc/bmc_src/key/privatekey
else
    ./extraction_vault $(docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$CONTAINER_NAME") 8200 > /builds/bmc/bmc_src/key/privatekey
fi
# останавливаем контейнер vault
# docker stop "$CONTAINER_NAME"
# переходим в дерикторию с проектом
cd /builds/bmc/bmc_src/

if [ "$long" = true ]; then
# Сборка с ключем 256 или 512
    ./docker_build.sh sign512 $DIR_NAME
else
    ./docker_build.sh sign $DIR_NAME
fi
