#include "contar_espacios.h"
#include <stdio.h>

uint32_t longitud_de_string(char* string) {
    uint32_t longitud = 0;
    if (string == NULL) {
        return longitud;
    }
    while (string[longitud] != '\0') {
        longitud++;
    }
    return longitud;
}

uint32_t contar_espacios(char* string) {
    uint32_t cantidad_espacios = 0;
    if (string == NULL)
        return cantidad_espacios;
    if (string[0] == '\0')
        return cantidad_espacios;
    if (string[0] == ' ')
        return 1 + contar_espacios(&string[1]);
    return contar_espacios(&string[1]);
}

// Pueden probar acá su código (recuerden comentarlo antes de ejecutar los tests!)
// int main() {
//     printf("1. %d\n", contar_espacios("hola como andas?"));
//     printf("2. %d\n", contar_espacios("holaaaa orga2"));
//     return 0;
// }
