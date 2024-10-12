/* ** por compatibilidad se omiten tildes **
================================================================================
 TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Rutinas del controlador de interrupciones.
*/
#include "pic.h"

#define PIC1_PORT 0x20
#define PIC2_PORT 0xA0

#define TIMER_TICK_CONTROL 0x43
#define TIMER_TICK_CHANNEL0 0x40

static __inline __attribute__((always_inline)) void outb(uint32_t port,
                                                         uint8_t data) {
  __asm __volatile("outb %0,%w1" : : "a"(data), "d"(port));
}
void pic_finish1(void) { outb(PIC1_PORT, 0x20); }
void pic_finish2(void) {
  outb(PIC1_PORT, 0x20);
  outb(PIC2_PORT, 0x20);
}

// COMPLETAR: implementar pic_reset()
void pic_reset() {
  // ================== PIC 1 ======================
  // icw1
  outb(PIC1_PORT, 0x11); // irqs activas x flanco, cascada, icw4
  // icw2
  outb(PIC1_PORT + 1, 32); // irq0-7 en 32-39
  // icw3
  outb(PIC1_PORT + 1, 4); // tiene un slave en irq2
  // icw4
  outb(PIC1_PORT + 1, 1); // modo no buffered, fin de interrupcion normal
  // ocw1
  outb(PIC1_PORT + 1, 0xFF); // deshabilito todas las interrupciones

  // ================== PIC 2 ======================
  // icw1
  outb(PIC2_PORT, 0x11); // irqs activas x flanco, cascada, icw4
  // icw2
  outb(PIC2_PORT + 1, 40); // irq8-15 en 40-47 (40 es el primer irq del pic2)
  // icw3
  outb(PIC2_PORT + 1, 2); // "Ey, PIC2, sos un slave del PIC1, estás en el irq2"
  // icw4
  outb(PIC2_PORT + 1, 1); // modo no buffered, fin de interrupcion normal
  // ocw1
  outb(PIC2_PORT + 1, 0xFF); // deshabilito todas las interrupciones
}

void pic_enable() {
  outb(PIC1_PORT + 1, 0x00);
  outb(PIC2_PORT + 1, 0x00);
}

void pic_disable() {
  outb(PIC1_PORT + 1, 0xFF);
  outb(PIC2_PORT + 1, 0xFF);
}

void pic_change_freq(){
  outb(TIMER_TICK_CONTROL, 0x36); 

  uint32_t base_divisor = 1 << 16;      // 65536
  uint16_t divisor = base_divisor / 2;  // 32768
  outb(TIMER_TICK_CHANNEL0, divisor & 0xFF); // envio los bytes menos significativos del divisor
  outb(TIMER_TICK_CHANNEL0, divisor >> 8); // envio los bytes mas significativos del divisor

  // parece no ser necesario enviar un pic finish aca. 
  }