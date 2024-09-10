#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "checkpoints.h"
#define ARR_LENGTH  2800

int main (void){
	char a[] = "Omega 4";
	uint32_t res = strLen(a);
	printf("res:%d\n", res);
}


