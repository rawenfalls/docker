FROM hashicorp/vault:latest

# Определение рабочей директории
WORKDIR /vault

# Копируем файлы/каталоги внутрь контейнера
COPY vault/config /vault/config
COPY vault/data /vault/data
COPY vault/logs /vault/logs

# Установка прав доступа IPC_LOCK
# RUN setcap cap_ipc_lock=+ep /usr/local/bin/vault

# Указание портов
EXPOSE 8200

# Копируем скрипт внутрь контейнера
COPY start.sh start.sh

# Устанавливаем права на выполнение для скрипта
RUN chmod +x start.sh

CMD ["server"]