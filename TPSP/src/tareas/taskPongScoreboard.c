#include "task_lib.h"

#define WIDTH TASK_VIEWPORT_WIDTH
#define HEIGHT TASK_VIEWPORT_HEIGHT

#define SHARED_SCORE_BASE_VADDR (PAGE_ON_DEMAND_BASE_VADDR + 0xF00)
#define CANT_PONGS 3

void task(void) {
	screen pantalla;
	while (true) {
		// initialize starting height at 5
		uint8_t height = 5;
		for (int task_idx = 0; task_idx < CANT_PONGS; task_idx++){
			// leo la cantidad de puntos actual, de la memoria compartida
			uint32_t* current_task_record = (uint32_t*) SHARED_SCORE_BASE_VADDR + (task_idx * sizeof(uint32_t)*2);
			uint32_t player1_score = current_task_record[0];
			uint32_t player2_score = current_task_record[1];


			// Imprimo el puntaje de los jugadores
			task_print(pantalla, "Puntaje jugador 1: ", 0, height, C_FG_WHITE);
			task_print_dec(pantalla, player1_score, 2, WIDTH * 0.75 + 3, height, C_FG_CYAN);
			task_print(pantalla, "Puntaje jugador 2: ", 0, height+1, C_FG_WHITE);
			task_print_dec(pantalla, player2_score, 2, WIDTH * 0.75 + 3, height+1, C_FG_CYAN);
			syscall_draw(pantalla);
			height += 4;
		}
	}
}
