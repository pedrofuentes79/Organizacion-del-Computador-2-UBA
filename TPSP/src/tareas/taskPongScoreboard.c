#include "task_lib.h"

#define WIDTH TASK_VIEWPORT_WIDTH
#define HEIGHT TASK_VIEWPORT_HEIGHT

#define SHARED_SCORE_BASE_VADDR (PAGE_ON_DEMAND_BASE_VADDR + 0xF00)
#define CANT_PONGS 3
void task(void) {
	screen pantalla;
	// ¿Una tarea debe terminar en nuestro sistema?
	while (true)
	{
	// Completar:
	// - Pueden definir funciones auxiliares para imprimir en pantalla
	// - Pueden usar `task_print`, `task_print_dec`, etc. 
	uint8_t h = 5;
	// armo un while para los tres pongs
		for (int i = 0; i < CANT_PONGS; i++)
		{
			uint32_t* current_record = (uint32_t*) SHARED_SCORE_BASE_VADDR + (i * sizeof(uint32_t)*2);
			// Imprimo el puntaje de los jugadores
            task_print(pantalla, "Puntaje jugador 1: ", 0, h, C_FG_WHITE);
			task_print_dec(pantalla, current_record[0], 2, WIDTH * 0.75 + 3, h, C_FG_CYAN);
			task_print(pantalla, "Puntaje jugador 2: ", 0, h+1, C_FG_WHITE);
			task_print_dec(pantalla, current_record[1], 2, WIDTH * 0.75 + 3, h+1, C_FG_CYAN);
			syscall_draw(pantalla);
			h += 4;
		}
	}
}
