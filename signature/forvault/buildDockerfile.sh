#!/bin/bash

# Переменные для настроек сборки forvault
DOCKERFILE_PATH="."  # Путь к Dockerfile
DOCKER_IMAGE="forvault"    # Имя и тег для собираемого образа
TAG="latest"

## Переменные для настроек сборки signvault
DOCKERFILE_PATH_SIGNVAULT="."  # Путь к Dockerfile
DOCKER_IMAGE_SIGNVAULT="signvault"    # Имя и тег для собираемого образа
TAG_SIGNVAULT="latest"

#флаг запуска контейнера после сборки
start=false

while [ "$#" -gt 0 ]; do
    case "$1" in
        -s|--start)
            start=true
            shift
            ;;
    esac
done


# Сборка extraction_vault
pip install pyinstaller
export PATH="$PATH:/home/$(whoami)/.local/bin" 
pyinstaller --onefile extraction_vault.py && cp dist/extraction_vault ./ && rm -rf build/ dist/ extraction_vault.spec 

cd ./images/signvault

# Сборка Docker signvault
docker build -t "$DOCKER_IMAGE_SIGNVAULT":"$TAG_SIGNVAULT" "$DOCKERFILE_PATH_SIGNVAULT"

cd ..

# Образ signvault.tar
docker save -o signvault.tar "$DOCKER_IMAGE_SIGNVAULT":"$TAG_SIGNVAULT"

cd ..

# Сборка Docker forvault
docker build -t "$DOCKER_IMAGE":"$TAG" "$DOCKERFILE_PATH"

#Удаление ненужных фалов
rm -rf extraction_vault images/.docker_temp_* images/signvault.tar

if [ "$start" = true ]; then
# Запуск для проверки
docker run --rm -it --name test_start --privileged forvault
fi