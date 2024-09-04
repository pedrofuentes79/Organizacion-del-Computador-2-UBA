#include "classify_chars.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

void classify_chars_in_string(char* string, char** vowels_and_cons) {
    int i = 0;
    while(string[i] != '\0'){
        char value = toupper(string[i]);
        int index = 1; // consontantes + otros caracteres
        if(value == 'A' || value == 'E'|| value == 'I' || value == 'O' || value == 'U'){
            index = 0; // vocales
        }
        size_t len = strlen(vowels_and_cons[index]);
        //vowels_and_cons[index] = realloc(vowels_and_cons[index],(len+2)*sizeof(char)); // actualizamos tamaño char*
        vowels_and_cons[index][len] = string[i]; // agregamos elemento
        vowels_and_cons[index][len+1] = '\0'; // fin de char*
        i++;
    }
}

void classify_chars(classifier_t* array, uint64_t size_of_array) {
    for(uint64_t i = 0; i < size_of_array; i++){
        // alocar memoria ACA
        array[i].vowels_and_consonants = malloc(2 * sizeof(char*));
        // podriamos usar calloc, pero no es necesario ya que solo queremos setear el primer valor en \0
        array[i].vowels_and_consonants[0] = malloc(64 * sizeof(char));
        array[i].vowels_and_consonants[1] = malloc(64 * sizeof(char));

        // inicializar strings
        array[i].vowels_and_consonants[0][0] = '\0';
        array[i].vowels_and_consonants[1][0] = '\0';

        classify_chars_in_string(array[i].string, array[i].vowels_and_consonants);
    }
}

