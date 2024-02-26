import hvac
import sys

# Проверяем, что было передано ровно 3 аргумента
if len(sys.argv) != 3 and len(sys.argv) != 1:
    print("Использование: python program.py arg1 arg2")
    sys.exit(1)
elif len(sys.argv) == 1:
    user_path = input("path: ")
else:
    user_path = sys.argv[1]
    user_password = sys.argv[2]
    
client = hvac.Client(
    url='http://0.0.0.0:8200',
    token='hvs.DjpcQZL4JlfivJefttacgLWX',
)
try:
    read_response = client.secrets.kv.v1.read_secret(user_path)
except Exception:
    print('Неверный path')
    sys.exit(1)

if 'data' in read_response:
    print("Путь найден")
    if len(sys.argv) == 1:
        user_password = input("password key: ")
    try:
        pass_key = read_response['data'][user_password]
    except Exception:
        print('Неверный password key')
        sys.exit(1)
    print("Секрет успешно прочитан:")
    print('-'*len(pass_key),'\n',pass_key,"\n",'-'*len(pass_key),sep='')
else:
    print("Неверный path")