#include "classify_chars.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

void classify_chars_in_string(char* string, char** vowels_and_cons) {
    vowels_and_cons = malloc(2 * sizeof(char*));

    vowels_and_cons[0] = malloc(64 * sizeof(char));
    vowels_and_cons[1] = malloc(64 * sizeof(char)); 


    // inicializo como strings vacios
    vowels_and_cons[0][0] = '\0';
    vowels_and_cons[1][0] = '\0';


    int i = 0;
    while(string[i] != '\0'){
        char value = toupper(string[i]);
        if(value == 'A' || value == 'E'|| value == 'I' || value == 'O' || value == 'U'){
            size_t len = strlen(vowels_and_cons[0]);
            // reallocamos el array para agregar un nuevo caracter
            vowels_and_cons[0] = realloc(vowels_and_cons[0],(len+2)*sizeof(char));
            vowels_and_cons[0][len] = string[i];
            vowels_and_cons[0][len+1] = '\0';
        }
        else if ('A' <= value && value <= 'Z'){
            size_t len = strlen(vowels_and_cons[1]);
            vowels_and_cons[1] = realloc(vowels_and_cons[1],(len+2)*sizeof(char));
            vowels_and_cons[1][len] = string[i];
            vowels_and_cons[1][len+1] = '\0';
        }
        i++;
    }
}

void classify_chars(classifier_t* array, uint64_t size_of_array) {
    for(uint64_t i = 0; i < size_of_array; i++){
        classify_chars_in_string(array[i].string, array[i].vowels_and_consonants);
    }
}
