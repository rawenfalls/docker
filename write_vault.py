import hvac

client = hvac.Client(
    url='http://127.0.0.1:8200',
    token='hvs.DjpcQZL4JlfivJefttacgLWX',
)

user_path = input("path: ")
user_password = input("password: ")

secret_data = {
    "password": user_password,
}

create_response = client.secrets.kv.v1.create_or_update_secret(
    path = 'foo',
    secret=dict(baz='baz'),
)

# create_response = client.secrets.kv.v2.create_or_update_secret(
#     path='my-secret-password',
#     secret=dict(password='Hashi123'),
# )

print('Secret written successfully.')