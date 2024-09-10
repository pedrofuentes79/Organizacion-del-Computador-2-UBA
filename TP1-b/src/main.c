#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "checkpoints.h"
#define ARR_LENGTH  2800

int main (void){
	uint32_t result = 0;
	product_2_f(&result, 2, 3.0);
	printf("result: %u\n", result);
}


