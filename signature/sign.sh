#!/bin/bash

current_directory="$PWD"

# echo "$current_directory"

# Получаем каталог, в котором находится скрипт
script_dir="$( cd "$( dirname $0 )" && pwd )"
#$0 предоставляет имя запущенного скрипта.
#dirname извлекает каталог из полного пути.
#cd сменяет текущий каталог на указанный.
#pwd возвращает текущий каталог.

#инициализация флага quiet (false выводит сообщение; true не выводит сообщение)
quiet=false

#инициализация флага make (true пересоберет программу подписи)
make=false

#инициализация флага long (true пересоберет программу для ключа 512 )
long=false

#путь к файлу источника(файл в котором храниться подпись)
source_file="$script_dir/../key/signature"

#путь к файлу в котором храниться публичный ключ
open_key="$script_dir/../key/publickey"

#путь к файлу в котором храниться приватный ключ
privat_key="$script_dir/../key/privatekey"

#считывает флаг -q|--quiet -m|--make
while [ "$#" -gt 0 ]; do
    case "$1" in
        -q|--quiet)
            quiet=true
            shift
            ;;
        -m|--make)
            make=true
            shift
            ;;
        -l|--long)
            long=true
            shift
            ;;
        -mq|-qm)
            make=true
            quiet=true
            shift
            ;;
        -lq|-ql)
            long=true
            quiet=true
            shift
            ;;
        *)
            destination_file="$1"
            shift 
            ;;
    esac
done

#проверяет не являеться ли переменная пустой
if [ -z "$destination_file" ]; then
    echo "Использование: $0 [-q|--quiet] файл_назначения(обычно *.ima) подпись будет скопированна в конец файла назначения"
    exit 1
fi

#проверка существования закрытого ключа
if [ ! -e "$privat_key" ]; then
    echo "Ошибка: Файл '$privat_key' не существует."
    exit 1
fi

cd "$script_dir"

#При наличии флага (-m|--make) скомпилирует make_sign_key
if [ "$make" = true ]; then
    if [ "$quiet" = false ]; then
        echo "Сборка: make_sign_key"
    fi
    make -B
fi

#При наличии флага (-l|--long) скомпилирует make_sign_key(key 512)
if [ "$long" = true ]; then
    if [ "$quiet" = false ]; then
        echo "Сборка: make_sign_key"
    fi
    make -B long
fi

#Если make_sign_key не существует, создаст его
if [ ! -e "./make_sign_key" ]; then
if [ "$long" = true ]; then
    make -B long
else
    make -B
fi
fi

#Проверяем, является ли переданный аргумент файлом или папкой
if [ -f "$destination_file" ]; then #файл
    # Проверяем, заканчивается ли имя файла на "ima"
    if [ "$destination_file" == *ima ]; then
        echo "Файл не заканчивается на 'ima'"
        exit 1
    fi
elif [ -d "$destination_file" ]; then #папка
    #Ищем файлы, оканчивающиеся на "ima" в указанной папке
    destination_file=$(find "$destination_file" -type f -name "*.ima" -print)
fi

#Если указан обсалютный путь до файла или скрипт и подписываемый файл лежат в одной папке 
if [[ "$destination_file" == /* ]] || [ "$script_dir" = "$current_directory" ]; then
    ./make_sign_key "$destination_file"
else
#Выходим в корень
    ./make_sign_key ../"$destination_file"
fi

# Проверяем код возврата
if [ $? -ne 0 ]; then
    echo "Ошибка при выполнении ./make_sign_key. Скрипт завершает работу."
    exit 1
fi

cd "$current_directory"

#проверка существования файла_источника
if [ ! -e "$source_file" ]; then
    echo "Ошибка: Файл '$source_file' не существует."
    exit 1
fi

#проверка существования файла_назначения
if [ ! -e "$destination_file" ]; then
    echo "Ошибка: Файл '$destination_file' не существует."
    exit 1
fi

#проверка существования публичного ключа
if [ ! -e "$open_key" ]; then
    echo "Ошибка: Файл '$open_key' не существует."
    exit 1
fi

# Добавление содержимого файла_источника(подпись) в конец файла_назначения
cat "$source_file" >> "$destination_file"

# Добавление содержимого open_key(открытый ключ) в конец файла_назначения
cat "$open_key" >> "$destination_file"

#путь к дериктории в которой храниться файл(*.ima)
# directory="$(dirname "$destination_file")"

#создаем папку key в дериктории с файлом (*.ima)
# mkdir -p "$directory"/rootfs/key

#копируем публичный ключ в папку key 
# cp "$open_key" "$directory/rootfs/key/"

#удаляем подпись из key
# rm -rf "$source_file"

#если флаг quiet == false выведет сообщение в консоль
if [ "$quiet" = false ]; then
    echo "Содержимое файла '$source_file' успешно добавлено в конец файла '$destination_file'."
fi