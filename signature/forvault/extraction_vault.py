import hvac
import sys

port = "8200"
ip = "0.0.0.0"
quiet = 0
if len(sys.argv) == 1:
    ip = input("ip: ")
    port = input("port: ")
    user_path = input("path: ")
    quiet = 1
elif len(sys.argv) == 2:
    port = sys.argv[1]
    user_path = "password"
    user_password = "password"
elif len(sys.argv) == 3:
    ip = sys.argv[1]
    port = sys.argv[2]
    user_path = "password"
    user_password = "password"
elif len(sys.argv) == 4:
    port = sys.argv[1]
    user_path = sys.argv[2]
    user_password = sys.argv[3]
else:
    ip = sys.argv[1]
    port = sys.argv[2]
    user_path = sys.argv[3]
    user_password = sys.argv[4]
    
client = hvac.Client(
    url="http://"+ip+":"+str(port),
    token='hvs.DjpcQZL4JlfivJefttacgLWX',
)
try:
    read_response = client.secrets.kv.v1.read_secret(user_path)
except Exception:
    print('Неверный path')
    sys.exit(1)

if 'data' in read_response:
    if(quiet):print("Путь найден")
    if len(sys.argv) == 1:
        user_password = input("password key: ")
    try:
        pass_key = read_response['data'][user_password]
    except Exception:
        print('Неверный password key')
        sys.exit(1)
    if(quiet):
        print("Секрет успешно прочитан:")
        print('-'*len(pass_key),'\n',pass_key,"\n",'-'*len(pass_key),sep='')
    else:
        print(pass_key)
else:
    print("Неверный path")