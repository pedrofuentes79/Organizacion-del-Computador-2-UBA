#include "classify_chars.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

void classify_chars_in_string(char* string, char** vowels_and_cons) {
    vowels_and_cons = malloc(2 * 64 * sizeof(char));
    int i = 0;
    while(string[i] != '\0'){
        char value = toupper(string[i]);
        if(value == 'A' || value == 'E'|| value == 'I' || value == 'O' || value == 'U'){
            size_t len = strlen(vowels_and_cons[0]);
            vowels_and_cons[0] = realloc(vowels_and_cons[0],(len+1)*sizeof(char));
            vowels_and_cons[0][len] = string[i];
        }
        else if ('A' <= value <= 'Z'){
            size_t len = strlen(vowels_and_cons[1]);
            vowels_and_cons[1] = realloc(vowels_and_cons[1],(len+1)*sizeof(char));
            vowels_and_cons[1][len] = string[i];
        }
        i++;
    }
    // Finalizamos los arrays agregando los '\0'   
    size_t len1 = strlen(vowels_and_cons[0]);
    vowels_and_cons[0] = realloc(vowels_and_cons[0],(len1+1)*sizeof(char));
    vowels_and_cons[0][len1] = '\0';

    size_t len2 = strlen(vowels_and_cons[1]);
    vowels_and_cons[1] = realloc(vowels_and_cons[1],(len1+1)*sizeof(char));
    vowels_and_cons[1][len1] = '\0';
}

void classify_chars(classifier_t* array, uint64_t size_of_array) {
    for(uint64_t i = 0; i < size_of_array; i++){
        classify_chars_in_string(array[i].string, array[i].vowels_and_consonants);
    }
}
