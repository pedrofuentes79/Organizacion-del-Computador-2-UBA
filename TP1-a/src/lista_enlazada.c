#include "lista_enlazada.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


lista_t* nueva_lista(void) {
    lista_t* l = malloc(sizeof(lista_t));
    l-> head = NULL; 
    return l;
}

uint32_t longitud(lista_t* lista) {
    uint32_t counter = 0;
    nodo_t* current = lista->head;
    while(lista->head != NULL) {
        counter++;
        current = current->next;
    }
    return counter;
}

void agregar_al_final(lista_t* lista, uint32_t* arreglo, uint64_t longitud) {
    nodo_t* n = malloc(sizeof(nodo_t));
    n->arreglo = arreglo;
    n->longitud = longitud;
    n->next = NULL;
    if(lista->head == NULL){
        lista->head = n;
    }else {
        nodo_t* current = lista->head;
        while (current->next != NULL) {
            current = current->next;
        }
        current->next = n;
    }
}

nodo_t* iesimo(lista_t* lista, uint32_t i) {
    uint32_t counter =0;
    nodo_t* current = lista->head;
    while(counter != i) {
        current = current->next;
        counter++;
    }
    return lista->head;
}

uint64_t cantidad_total_de_elementos(lista_t* lista) {
    uint64_t counter = 0;
    nodo_t* current = lista->head;
    while(lista->head != NULL) {
        counter += lista->head->longitud;
        current = current->next;
    }
    return counter;
}

void imprimir_lista(lista_t* lista) {
    nodo_t* current = lista->head;
    while(lista->head != NULL) {
        printf("| %I64u | -> ", lista->head->longitud);
        current = current->next;
    }
    printf("null\n");
}

// Función auxiliar para lista_contiene_elemento
int array_contiene_elemento(uint32_t* array, uint64_t size_of_array, uint32_t elemento_a_buscar) {
    for (size_t i = 0; i < size_of_array; i++)
    {
        if (array[i] == elemento_a_buscar)
        {
            return 1;
        }
    }
    return 0;
}

int lista_contiene_elemento(lista_t* lista, uint32_t elemento_a_buscar){
    while(lista -> head != NULL){
        if (array_contiene_elemento(lista->head->arreglo,lista->head->longitud, elemento_a_buscar))
        {
            return 1;
        }
        lista-> head = lista->head->next;
        }
    return 0;
}


// Devuelve la memoria otorgada para construir la lista indicada por el primer argumento.
// Tener en cuenta que ademas, se debe liberar la memoria correspondiente a cada array de cada elemento de la lista.
void destruir_lista(lista_t* lista) {
    nodo_t* n = lista->head;
    while(n){
        nodo_t* tmp = n;
        n = n->next;
        free(tmp);
    }
    free(lista);
}