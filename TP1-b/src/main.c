#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "checkpoints.h"
#define ARR_LENGTH  2800

int main (void){
	
	// inicializar un x de arr_length con cosas ahi
	nodo_t *array[ARR_LENGTH];
	uint32_t x[ARR_LENGTH];
	for (int i = 0; i < ARR_LENGTH; i++) {
		x[i] = i*2;
	}

	for(int j=0; j<ARR_LENGTH; j++){
		array[j] = calloc(1, sizeof(nodo_t));
		array[j]->longitud = x[j];
	}

	for(int j=0; j<ARR_LENGTH-1; j++){
		array[j]->next = array[j+1];
	}

	lista_t lista;
	lista.head = array[0];

	nodo_t* nodo = lista.head;
	uint32_t result = 0;

	while(nodo != NULL){
		result += nodo->longitud;
		nodo = nodo->next;
	}

	printf("Cantidad total de elementos POSTA: %d\n", result);
	uint32_t my_res = cantidad_total_de_elementos(&lista);
	printf("Cantidad total de elementos: %d\n", my_res);

	for(int j=0; j<ARR_LENGTH; j++){
		free(array[j]);
	}

	return 1;
}


