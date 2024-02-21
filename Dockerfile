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
COPY start.sh /usr/local/bin/

# Устанавливаем права на выполнение для скрипта
RUN chmod +x /usr/local/bin/start.sh

CMD ["server"]
