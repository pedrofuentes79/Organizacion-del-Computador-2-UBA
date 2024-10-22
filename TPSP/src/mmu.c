/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definicion de funciones del manejador de memoria
*/

#include "mmu.h"
#include "i386.h"

#include "kassert.h"

static pd_entry_t* kpd = (pd_entry_t*)KERNEL_PAGE_DIR;
static pt_entry_t* kpt = (pt_entry_t*)KERNEL_PAGE_TABLE_0;

static const uint32_t identity_mapping_end = 0x003FFFFF;
// static const uint32_t user_memory_pool_end = 0x02FFFFFF;

static paddr_t next_free_kernel_page = 0x100000;
static paddr_t next_free_user_page = 0x400000;

/**
 * kmemset asigna el valor c a un rango de memoria interpretado
 * como un rango de bytes de largo n que comienza en s
 * @param s es el puntero al comienzo del rango de memoria
 * @param c es el valor a asignar en cada byte de s[0..n-1]
 * @param n es el tamaño en bytes a asignar
 * @return devuelve el puntero al rango modificado (alias de s)
*/
static inline void* kmemset(void* s, int c, size_t n) {
  uint8_t* dst = (uint8_t*)s;
  for (size_t i = 0; i < n; i++) {
    dst[i] = c;
  }
  return dst;
}

/**
 * zero_page limpia el contenido de una página que comienza en addr
 * @param addr es la dirección del comienzo de la página a limpiar
*/
static inline void zero_page(paddr_t addr) {
  kmemset((void*)addr, 0x00, PAGE_SIZE);
}


void mmu_init(void) {}


/**
 * mmu_next_free_kernel_page devuelve la dirección física de la próxima página de kernel disponible. 
 * Las páginas se obtienen en forma incremental, siendo la primera: next_free_kernel_page
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de kernel
 */
paddr_t mmu_next_free_kernel_page(void) {
  paddr_t free_page = next_free_kernel_page;
  next_free_kernel_page += PAGE_SIZE;
  return free_page;
}

/**
 * mmu_next_free_user_page devuelve la dirección de la próxima página de usuarix disponible
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de usuarix
 */
paddr_t mmu_next_free_user_page(void) {
  paddr_t free_page = next_free_user_page;
  next_free_user_page += PAGE_SIZE;
  return free_page;
}

/**
 * mmu_init_kernel_dir inicializa las estructuras de paginación vinculadas al kernel y
 * realiza el identity mapping
 * @return devuelve la dirección de memoria de la página donde se encuentra el directorio
 * de páginas usado por el kernel
 */

paddr_t mmu_init_kernel_dir(void) {
  // para hacer el identity mapping, la idea es tener un directorio de tablas de paginas de kernel
  // de 0x0 a 0x3FFFFF necesito 1024 paginas. Osea, una tabla de paginas :)

  // limpio el dir y la tabla
  zero_page((paddr_t)kpd);
  zero_page((paddr_t)kpt);

  // la primera entrada de la kpd va a tener la direccion de memoria de la kpt 
  // ponemos kpt[0] porque la direccion de memoria de la tabla de paginas es la su primer entrada
  // shifteo 12 bits para que quede con offset = 0,
  // ya que los primeros 20 bits son la direccion y el resto atributos
  kpd[0].pt = ((uint32_t)&kpt[0]) >> 12;
  kpd[0].attrs = MMU_P | MMU_W; // present y writable (le tengo que mapear cosas, asi que lo tengo que escribir)

  // identity mapping
  paddr_t current_page = 0;
  uint32_t i = 0;
  while (current_page <= identity_mapping_end){
    kpt[i].page = current_page >> 12; // guardo el page frame
    kpt[i].attrs = MMU_P | MMU_W;     // present y writable

    current_page = current_page + PAGE_SIZE;
    i++;
  }

  return (paddr_t) kpd;

}

/**
 * mmu_map_page agrega las entradas necesarias a las estructuras de paginación de modo de que
 * la dirección virtual virt se traduzca en la dirección física phy con los atributos definidos en attrs
 * @param cr3 el contenido que se ha de cargar en un registro CR3 al realizar la traducción
 * @param virt la dirección virtual que se ha de traducir en phy
 * @param phy la dirección física que debe ser accedida (dirección de destino)
 * @param attrs los atributos a asignar en la entrada de la tabla de páginas
 */
void mmu_map_page(uint32_t cr3, vaddr_t virt, paddr_t phy, uint32_t attrs) {

  pd_entry_t* pd = (pd_entry_t*)CR3_TO_PAGE_DIR(cr3);
  uint32_t pd_index = VIRT_PAGE_DIR(virt);

  // si la tabla de paginas no esta presente, la tengo que crear
  if (!(pd[pd_index].attrs & MMU_P)) {
    // tengo que buscar una pagina libre para la tabla de paginas
    paddr_t new_table = mmu_next_free_kernel_page();
    pd[pd_index].pt = new_table >> 12;
    pd[pd_index].attrs = MMU_P | MMU_W; // present y writable
    zero_page(new_table);
  }
  


  pt_entry_t* pt = (pt_entry_t*)MMU_ENTRY_PADDR(pd[pd_index].pt);  
  uint32_t pt_index = VIRT_PAGE_TABLE(virt);

  pt[pt_index].page = phy >> 12;
  pt[pt_index].attrs = attrs;

  tlbflush();

}

/**
 * mmu_unmap_page elimina la entrada vinculada a la dirección virt en la tabla de páginas correspondiente
 * @param virt la dirección virtual que se ha de desvincular
 * @return la dirección física de la página desvinculada
 */
paddr_t mmu_unmap_page(uint32_t cr3, vaddr_t virt) {
  pd_entry_t* pd = (pd_entry_t*)CR3_TO_PAGE_DIR(cr3);
  uint32_t pd_index = VIRT_PAGE_DIR(virt);
  pt_entry_t* pt = (pt_entry_t*)MMU_ENTRY_PADDR(pd[pd_index].pt);
  uint32_t pt_index = VIRT_PAGE_TABLE(virt);

  // chequeo si esta presente
  if (!(pt[pt_index].attrs & MMU_P)) {
    // setearla en 0?
    return 0;
  }

  paddr_t page_to_unmap = (pt[pt_index].page << 12) | VIRT_PAGE_OFFSET(virt);

  // seteo la pagina como "no presente"
  pt[pt_index].attrs = pt[pt_index].attrs & (~MMU_P);
  // podria ponerla toda en ceros?

  tlbflush();
  return page_to_unmap;
}

#define DST_VIRT_PAGE 0xA00000
#define SRC_VIRT_PAGE 0xB00000

/**
 * copy_page copia el contenido de la página física localizada en la dirección src_addr a la página física ubicada en dst_addr
 * @param dst_addr la dirección a cuya página queremos copiar el contenido
 * @param src_addr la dirección de la página cuyo contenido queremos copiar
 *
 * Esta función mapea ambas páginas a las direcciones SRC_VIRT_PAGE y DST_VIRT_PAGE, respectivamente, realiza
 * la copia y luego desmapea las páginas. Usar la función rcr3 definida en i386.h para obtener el cr3 actual
 */
void copy_page(paddr_t dst_addr, paddr_t src_addr) {
  // necesito mapearlas a alguna direccion virtual! 
  // si no, no puedo acceder a ellas para hacer la copia
  mmu_map_page(rcr3(), DST_VIRT_PAGE, dst_addr, MMU_P | MMU_W);
  mmu_map_page(rcr3(), SRC_VIRT_PAGE, src_addr, MMU_P | MMU_W);


  // obtengo los punteros a cada una
  uint8_t* src = (uint8_t*)SRC_VIRT_PAGE;
  uint8_t* dst = (uint8_t*)DST_VIRT_PAGE;

  // copio
  for (size_t i = 0; i < PAGE_SIZE; i++) {
    dst[i] = src[i];
  }

  // las desmapeo de estas direcciones virtuales auxiliares
  // mmu_unmap_page(rcr3(), DST_VIRT_PAGE);
  // mmu_unmap_page(rcr3(), SRC_VIRT_PAGE);
}

/**
 * mmu_init_task_dir inicializa las estructuras de paginación vinculadas a una tarea cuyo código se encuentra en la dirección phy_start
 * @param phy_start es la dirección donde comienzan las dos páginas de código de la tarea asociada a esta llamada
 * @return el contenido que se ha de cargar en un registro CR3 para la tarea asociada a esta llamada
 */
paddr_t mmu_init_task_dir(paddr_t phy_start) {
  // Inicializar estructuras de paginacion
  pd_entry_t* tpd = (pd_entry_t*)mmu_next_free_user_page(); // de user, no de kernel
  pt_entry_t* tpt = (pt_entry_t*)mmu_next_free_user_page();
  tpt = tpt + 2;
  // ACA TIRA PAGE FAULT
  // zero_page((paddr_t)tpd);
  // zero_page((paddr_t)tpt);
  
  // Mapear las dos paginas de codigo como solo lectura (a partir de 0x08000000)
  mmu_map_page(rcr3(), TASK_CODE_VIRTUAL, phy_start, MMU_P);
  mmu_map_page(rcr3(), TASK_CODE_VIRTUAL + PAGE_SIZE, phy_start + PAGE_SIZE, MMU_P);

  // Mapear la pagina de stack como lectura/escritura (a partir de 0x08003000)
  mmu_map_page(rcr3(), TASK_STACK_BASE, mmu_next_free_user_page(), MMU_P | MMU_W);  

  // Mapear la pagina de memoria compartida como lectura/escritura (despues del stack)
  mmu_map_page(rcr3(), TASK_STACK_BASE + PAGE_SIZE, mmu_next_free_user_page(), MMU_P | MMU_W);

  return (paddr_t)tpd;
}

// COMPLETAR: devuelve true si se atendió el page fault y puede continuar la ejecución 
// y false si no se pudo atender
bool page_fault_handler(vaddr_t virt) {
  print("Atendiendo page fault...", 0, 0, C_FG_WHITE | C_BG_BLACK);
  // Chequeemos si el acceso fue dentro del area on-demand
  // En caso de que si, mapear la pagina

  if (virt >= ON_DEMAND_MEM_START_VIRTUAL && virt < ON_DEMAND_MEM_END_VIRTUAL){
    // el acceso es valido
    // mapeo con r/w, user-level
    mmu_map_page(rcr3(), virt, mmu_next_free_user_page(), MMU_P | MMU_W);
    return true;
  }
  else {
    print("ERROR: ACCESO FUERA DE RANGO", 0, 0, C_FG_WHITE | C_BG_BLACK);
    return false;
  }

}
