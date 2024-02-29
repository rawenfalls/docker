#!/bin/bash

# Переменные для настроек сборки forvault
DOCKERFILE_PATH="."  # Путь к Dockerfile
DOCKER_IMAGE="forvault"    # Имя для собираемого образа
TAG="latest"    # Тег для собираемого образа

## Переменные для настроек сборки signvault
DOCKERFILE_PATH_SIGNVAULT="."  # Путь к Dockerfile
DOCKER_IMAGE_SIGNVAULT="signvault"    # Имя и тег для собираемого образа
TAG_SIGNVAULT="latest" # Тег для собираемого образа

#флаг запуска контейнера после сборки
start=false

while [ "$#" -gt 0 ]; do
    case "$1" in
        -s|--start)
            start=true
            shift
            ;;
        *)
            TAG="$1"
            shift 
            ;;
    esac
done

# Сборка extraction_vault
pip install pyinstaller
export PATH="$PATH:/home/$(whoami)/.local/bin"
pip install hvac
pyinstaller --onefile extraction_vault.py && cp dist/extraction_vault ./ && rm -rf build/ dist/ extraction_vault.spec 

cd ./images/signvault

# без этого, если БД была редактирована, при запуске контейнера внутри контейнера будет падать в ошибку 
sudo chmod -R 777 vault/

# Сборка Docker signvault
docker build -t "$DOCKER_IMAGE_SIGNVAULT":"$TAG_SIGNVAULT" "$DOCKERFILE_PATH_SIGNVAULT"

cd ..

# Образ signvault.tar
docker save -o signvault.tar "$DOCKER_IMAGE_SIGNVAULT":"$TAG_SIGNVAULT"

cd ..

# Сборка Docker forvault
docker build -t "$DOCKER_IMAGE":"$TAG" "$DOCKERFILE_PATH"

# #Удаление ненужных фалов
rm -rf extraction_vault images/.docker_temp_* images/signvault.tar

if [ "$start" = true ]; then
# Запуск для проверки
docker run --rm -it --name test_start --privileged forvault
fi