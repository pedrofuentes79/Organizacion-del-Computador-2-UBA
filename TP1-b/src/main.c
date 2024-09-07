#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "checkpoints.h"

int main (void){
	uint32_t x[9] = {1, 2, 3, 4, 5, 6, 7, 8, 9};
	float f[9] = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0};

	double expected = f[0] * f[1] * f[2] * f[3] * f[4] * f[5] * f[6] * f[7] * f[8]
		* x[0] * x[1] * x[2] * x[3] * x[4] * x[5] * x[6] * x[7] * x[8];
	double result = 1.0/0.0;
    product_9_f(&result, x[0], f[0], x[1], f[1], x[2], f[2], x[3], f[3],x[4], f[4], x[5], f[5], x[6], f[6], x[7], f[7], x[8], f[8]);

	printf("Expected: %f\n", expected);
	printf("Result: %f\n", result);
	return 0;
}


