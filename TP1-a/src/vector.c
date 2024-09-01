#include "vector.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


vector_t* nuevo_vector(void) {
    // alocar memoria para el vector
    vector_t* vector = malloc(sizeof(vector_t));
    vector->size = 0;
    vector->capacity = 2;
    // alocar memoria para el arreglo al que apunta el vector
    // uso sizeof uint32_t porque ese es el tipo de dato que va en cada pos del array
    vector->array = malloc(sizeof(uint32_t) * (vector->capacity));
    return vector;
}

uint64_t get_size(vector_t* vector) {
    return vector->size;
}

void push_back(vector_t* vector, uint32_t elemento) {
    // si no entra en el array que tenemos, tenemos que asignarle mas memoria!

    // chequeo si el array ya esta lleno
    if(vector->size == vector->capacity){
        // duplico capacidad (podria ser otra medida, como agregar uno, pero asi evito tantos llamados a realloc)
        vector->capacity = vector->capacity * 2;

        // re-alocar memoria! esto toma el puntero (ya alocado) y el tamaño nuevo
        // si hay espacio contiguo en la memoria para agregarle al final, lo hace;
        // si no, lo mueve a otro lado donde haya espacio suficiente y copia los contenidos.
        vector->array = realloc(vector->array, vector->capacity * sizeof(uint32_t));
    }
    
    // agrego el elemento al final
    vector->array[vector->size] = elemento;
    vector->size++;
}

int son_iguales(vector_t* v1, vector_t* v2) {
    if (v1->size != v2->size){
        return 0;
    }

    for (size_t i = 0; i < v1->size; i++){
        if (v1->array[i] != v2->array[i]){
            return 0;
        }
    }
    return 1;

}

uint32_t iesimo(vector_t* vector, size_t index) {
    if (index >= vector->size){
        return 0;
    }
    return vector->array[index];
}

void copiar_iesimo(vector_t* vector, size_t index, uint32_t* out){
    *out = iesimo(vector, index);
}


// Dado un array de vectores, devuelve un puntero a aquel con mayor longitud.
vector_t* vector_mas_grande(vector_t** array_de_vectores, size_t longitud_del_array) {
    vector_t* maximo = NULL;
    for(size_t i = 0; i < longitud_del_array; i++){
        if (maximo == NULL || array_de_vectores[i]->size > maximo->size)
            maximo = array_de_vectores[i];
    }
    return maximo;
}
