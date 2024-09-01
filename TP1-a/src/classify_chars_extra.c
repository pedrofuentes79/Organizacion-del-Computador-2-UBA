#include "classify_chars.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

typedef struct {
    char *vowels;
    char *cons;
} classifier_v3_t;

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

classifier_v3_t classify_chars_in_string_v3(char* string) {
    // allocate memory for struct
    classifier_v3_t* result = malloc(sizeof(classifier_v3_t));

    // allocate memory for vowels and cons
    result->vowels = malloc(64 * sizeof(char));
    result->cons = malloc(64 * sizeof(char));
    result->vowels[0] = '\0';
    result->cons[0] = '\0';

    // reuso la anterior funcion, que hace exactamente lo mismo que haria aca, pero ahora devuelvo un struct
    classify_chars_in_string_v2(string, result->vowels, result->cons);

    // desreferencio el puntero para devolver el struct, y no el puntero al struct
    return *result;
}

classifier_v3_t* classify_chars_v3(char** strings, uint64_t size_of_array) {
    // array de structs
    classifier_v3_t* results = malloc(size_of_array * sizeof(classifier_v3_t));

    for(uint64_t i = 0; i < size_of_array; i++){
        results[i] = classify_chars_in_string_v3(strings[i]);
    }

    return results;
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
    // free memory
    for(int i = 0; i < 4; i++){
        free(vowels[i]);
        free(cons[i]);
    }
    // no hace falta hacerle free a strings, vowels y cons, ya que son arrays en el stack

    // test the v3 functions
    classifier_v3_t* results = classify_chars_v3(strings, 4);
    for(int i = 0; i < 4; i++){
        printf("Vowels: %s\n", results[i].vowels);
        printf("Cons: %s\n", results[i].cons);
    }
    // free memory
    for(int i = 0; i < 4; i++){
        free(results[i].vowels);
        free(results[i].cons);
    }

    return 0;
}