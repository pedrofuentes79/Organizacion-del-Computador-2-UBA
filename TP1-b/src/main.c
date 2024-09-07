#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "checkpoints.h"

#include "test-utils.h"
#include "checkpoints.h"

#define ARR_LENGTH  4
#define ROLL_LENGTH 10

static uint32_t x[ROLL_LENGTH];
static double   f[ROLL_LENGTH];

void shuffle(uint32_t max){
	for (int i = 0; i < ROLL_LENGTH; i++) {
		x[i] = (uint32_t) rand() % max;
        	f[i] = ((float)rand()/(float)(RAND_MAX)) * max;
	}
}
int main (void){
	for (int i = 0; i < 100; i++) {
		shuffle(1000);
		printf("product_2_f(&result, %u, %.2f)", x[0], f[0]);

		uint32_t result = -1;
		product_2_f(&result, x[0], f[0]);
		printf("result: %u\n. %u", result, x[0]*f[0]);
		assert(result == x[0]*f[0]);
	}
}


