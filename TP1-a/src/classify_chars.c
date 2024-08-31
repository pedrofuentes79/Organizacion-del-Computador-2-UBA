#include "classify_chars.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

void classify_chars_in_string(char* string, char** vowels_and_cons) {
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
        else {
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


void classify_chars_in_string_v2(char* string, char* vowels, char* cons) {
    int i = 0;
    while(string[i] != '\0'){
        char value = toupper(string[i]);
        if(value == 'A' || value == 'E'|| value == 'I' || value == 'O' || value == 'U'){
            size_t len = strlen(vowels);
            // reallocamos el array para agregar un nuevo caracter
            vowels = realloc(vowels,(len+2)*sizeof(char));
            vowels[len] = string[i];
            vowels[len+1] = '\0';
        }
        else {
            size_t len = strlen(cons);
            cons = realloc(cons,(len+2)*sizeof(char));
            cons[len] = string[i];
            cons[len+1] = '\0';
        }
        i++;
    }
}

// esta funcion recibe un array de strings y dos punteros, uno al arreglo de vocales y otro al arreglo de consonantes
void classify_chars_v2(char** strings, uint64_t size_of_array, char**vowels, char** cons) {
    for(uint64_t i = 0; i < size_of_array; i++){
        // allocate memory for vowels and cons
        vowels[i] = malloc(64 * sizeof(char));
        cons[i] = malloc(64 * sizeof(char));
        vowels[i][0] = '\0';
        cons[i][0] = '\0';
    
        classify_chars_in_string_v2(strings[i], vowels[i], cons[i]);
    }
}





int main() {
    // test the v2 functions
    char* strings[] = {"orga", "dos", "segundo", "cuatri"};
    char* vowels[4];
    char* cons[4];
    classify_chars_v2(strings, 4, vowels, cons);
    for(int i = 0; i < 4; i++){
        printf("Vowels: %s\n", vowels[i]);
        printf("Cons: %s\n", cons[i]);
    }
    return 0;
}