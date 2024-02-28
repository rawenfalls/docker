#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libakrypt.h>

/*! @brief записывает в файл key/signature подпись
    @param sign - ak_uint8 sign[128]
    @return int 0 успех, 1 в случае ошибки               
*/
static int signature_write_file(ak_uint8 sign[128])
{
    FILE *file = fopen("../key/signature", "wb");
    if (file == NULL) {
        perror("Не удалось открыть файл");
        return 1;
    }

    for (int i=0; i<128; i++)
        fprintf(file,"%02x",sign[i]);

    fclose(file);

    return 0;
}

/*! @brief записывает в файл key/publickey структуру verifykey
 * 
 * @param pk структура verifykey
 * @return int 0 в случа успеха; 1 ошибка 
 */
static int publickey_write_file(struct verifykey pk)
{
    // Открываем файл для записи (режим "wb" - write binary)
    FILE *file = fopen("../key/publickey", "wb");
    if (file == NULL) {
        perror("Не удалось открыть файл");
        return 1;
    }

    //Записываем кординаты ключа в файл в 16 ричной системе
    #ifdef LONG512
    for (int i = 0; i < 24; i++) {
        if(i>=0 && i<8)fprintf(file, "%016llx", pk.qpoint.x[i]);
        if(i>=8 && i<16)fprintf(file, "%016llx", pk.qpoint.y[i-8]);
        if(i>=16 && i<24)fprintf(file, "%016llx", pk.qpoint.z[i-16]);
    }
    #else
    for (int i = 0; i < 12; i++) {
        if(i>=0 && i<4)fprintf(file, "%016llx", pk.qpoint.x[i]);
        if(i>=4 && i<8)fprintf(file, "%016llx", pk.qpoint.y[i-4]);
        if(i>=8 && i<12)fprintf(file, "%016llx", pk.qpoint.z[i-8]);
    }
    #endif

    #ifdef DEBUG
    for (int i = 0; i < 12; i++) {
        if(i==0) printf("publickey:\nX:\n");
        else if(i==4) printf("Y:\n");
        else if(i==8) printf("Z:\n");

        if(i>=0 && i<4)printf("%016llx\n", pk.qpoint.x[i]);
        if(i>=4 && i<8)printf("%016llx\n", pk.qpoint.y[i-4]);
        if(i>=8 && i<12)printf("%016llx\n", pk.qpoint.z[i-8]);
    }
    #endif

    // Закрываем файл
    fclose(file);
    
    return 0;
}

/*! @brief записывает в массив значение ключа из фала key/privatekey
    @param privatkey - ak_uint8 (*privatkey)[32] 
    @return int 0 успех, 1 в случае ошибки                                                                                   
*/
static int read_privatkey(ak_uint8 (*privatkey)[32], int len)
{
    len = len * 2;
    char buffer[len];
    char result[3];
    result[2]='\0';

    FILE *file = fopen("../key/privatekey", "rb");
    if (file == NULL) {
        perror("Ошибка при открытии файла");
        return 1;
    }
    
    if (len != fread(buffer, 1, len, file)){
        perror("fread() неверная длинна");
        return 1;
    }

    fclose(file);

    // for(int i=0; i<64; i++)
    //     printf("%c",buffer[i]);
    // printf("\n");

    for (int i = 0; i<len/2; i++){
        result[0] = buffer[i*2];
        result[1] = buffer[i*2+1];
        (*privatkey)[i] = (unsigned char)strtol(result, NULL, 16);
    }

    #ifdef DEBUG
    for(int i=0; i<len/2; i++)
        printf("%02x",(*privatkey)[i]);
    printf("\n");
    #endif
    
    return 0;
}

/*! @brief Создает ключ и подпись, после чего записывает их в файл key/publickey и signature/signature соответственно
 * 
 * @return int вернет 0, если ключ валидный, 1 в случае ошибки или если ключ не валидный
 */
int main(int argc, char *argv[])
{
    if (argc != 2) {
        fprintf(stderr, "Использование: %s <путь_к_*.ima>\n", argv[0]);
        return EXIT_FAILURE;
    }

    struct signkey sk;
    struct verifykey pk;
    struct random generator;
    int result = EXIT_SUCCESS;
    ak_uint8 sign[128];
    #ifdef LONG512
    int len = 64;
    #else
    int len = 32;
    #endif
    ak_uint8 privatkey[len];

    /* читает приватный ключ из файла */
    if (read_privatkey(&privatkey, len)) return 1;

    // for(int i=0; i<32; i++)
    //     printf("%02x",privatkey[i]);
    // printf("\n");

    /* создаем генератор псевдослучайных последовательностей */
    if( ak_random_create_lcg( &generator ) != ak_error_ok ) {
        ak_libakrypt_destroy();
        return EXIT_FAILURE;
    }

    /* инициализируем секретный ключ с заданной эллиптической кривой */
    //Параметры 256-ти битной эллиптической кривой из тестов ГОСТ
    // if( ak_signkey_create_str( &sk, "id-tc26-gost-3410-2012-256-paramSetTest") != ak_error_ok ) {
    //Параметры 256-ти битной эллиптической кривой из примера
    // if( ak_signkey_create_str( &sk, "cspa") != ak_error_ok ) {
    #ifdef LONG512
    //Параметры 512-ти битной эллиптической кривой из рекомендаций Р 50.1.114-2016
    if( ak_signkey_create_str( &sk, "id-tc26-gost-3410-2012-512-paramSetA") != ak_error_ok )
    #else
    //Параметры 256-ти битной эллиптической кривой из рекомендаций Р 50.1.114-2016
    if( ak_signkey_create_str( &sk, "id-tc26-gost-3410-2012-256-paramSetA") != ak_error_ok )
    #endif
    {
        result = EXIT_FAILURE;
        ak_random_destroy( &generator );
        return result;
    }

    /* устанавливаем значение ключа */
    ak_signkey_set_key( &sk, privatkey, len );

    /* подстраиваем ключ и устанавливаем ресурс */
    ak_skey_set_resource_values( &sk.key, key_using_resource,
                "digital_signature_count_resource", 0, time(NULL)+2592000 );

    /* только теперь подписываем данные
        в качестве которых выступает исполняемый файл */
    ak_signkey_sign_file( &sk, &generator, argv[1], sign, sizeof( sign ));
    #ifdef DEBUG
    printf("file:   %s\nsign:   %s\n", argv[1],
            ak_ptr_to_hexstr( sign, ak_signkey_get_tag_size(&sk), ak_false ));
    #endif

    /* формируем открытый ключ */
    ak_verifykey_create_from_signkey( &pk, &sk );

    /* записывает подпись в файл */
    if (signature_write_file(sign)) return 1;

    /*записываем публичный ключ в файл*/
    if (publickey_write_file(pk)) return 1;

    /* проверяем подпись */
    if( ak_verifykey_verify_file( &pk, argv[1], sign ) == ak_true )
        printf("verify: Ok\n");
    else { printf("verify: Wrong\n"); result = EXIT_FAILURE; }

    ak_signkey_destroy( &sk );
    ak_verifykey_destroy( &pk );
    ak_random_destroy( &generator );
    
    return result;
}
