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
    uint32_t longitud = longitud_de_string(string);
    for (uint32_t i = 0; i < longitud; i++) {
        if (string[i] == ' ') {
            cantidad_espacios++;
        }
    }
    return cantidad_espacios;
}

// Pueden probar acá su código (recuerden comentarlo antes de ejecutar los tests!)
/*
int main() {

    printf("1. %d\n", contar_espacios("hola como andas?"));

    printf("2. %d\n", contar_espacios("holaaaa orga2"));
}
*/