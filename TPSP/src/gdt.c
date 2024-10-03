/* ** por compatibilidad se omiten tildes **
==============================================================================
TALLER System Programming - Arquitectura y Organizacion de Computadoras - FCEN
==============================================================================

  Definicion de la tabla de descriptores globales
*/

#include "gdt.h"
#include "defines.h"

/* Aca se inicializa un arreglo de forma estatica
GDT_COUNT es la cantidad de líneas de la GDT y esta definido en defines.h */

gdt_entry_t gdt[GDT_COUNT] = {
    /* Descriptor nulo*/
    /* Offset = 0x00 */
    [GDT_IDX_NULL_DESC] =
        {
            // El descriptor nulo es el primero que debemos definir siempre
            // Cada campo del struct se matchea con el formato que figura en el manual de intel
            // Es una entrada en la GDT.
            .limit_15_0 = 0x0000,
            .base_15_0 = 0x0000,
            .base_23_16 = 0x00,
            .type = 0x0,
            .s = 0x00,
            .dpl = 0x00,
            .p = 0x00,
            .limit_19_16 = 0x00,
            .avl = 0x0,
            .l = 0x0,
            .db = 0x0,
            .g = 0x00,
            .base_31_24 = 0x00,
        },

    [GDT_IDX_CODE_0] =
        {
            // El descriptor nulo es el primero que debemos definir siempre
            // Cada campo del struct se matchea con el formato que figura en el manual de intel
            // Es una entrada en la GDT.
            .limit_15_0 = GDT_LIMIT_4KIB(FLAT_SEGM_SIZE) & (0x0000FFFF),
            .base_15_0 = 0x0000,
            .base_23_16 = 0x00,
            .type = DESC_TYPE_EXECUTE_READ,
            .s = DESC_CODE_DATA,
            .dpl = 0x00,
            .p = 0x01,
            .limit_19_16 = GDT_LIMIT_4KIB(FLAT_SEGM_SIZE) >> 16,
            .avl = 0x0,
            .l = 0x0,
            .db = 0x0,
            .g = 0x01,
            .base_31_24 = 0x00,
        },
      [GDT_IDX_CODE_3] =
        {
            // El descriptor nulo es el primero que debemos definir siempre
            // Cada campo del struct se matchea con el formato que figura en el manual de intel
            // Es una entrada en la GDT.
            .limit_15_0 = GDT_LIMIT_4KIB(FLAT_SEGM_SIZE) & (0x0000FFFF),
            .base_15_0 = 0x0000,
            .base_23_16 = 0x00,
            .type = DESC_TYPE_EXECUTE_READ,
            .s = DESC_CODE_DATA,
            .dpl = 0x03,
            .p = 0x01,
            .limit_19_16 = GDT_LIMIT_4KIB(FLAT_SEGM_SIZE) >> 16,
            .avl = 0x0,
            .l = 0x0,
            .db = 0x0,
            .g = 0x01,
            .base_31_24 = 0x00,
        },
        [GDT_IDX_DATA_0] =
        {
            // El descriptor nulo es el primero que debemos definir siempre
            // Cada campo del struct se matchea con el formato que figura en el manual de intel
            // Es una entrada en la GDT.
            .limit_15_0 = GDT_LIMIT_4KIB(FLAT_SEGM_SIZE) & (0x0000FFFF),
            .base_15_0 = 0x0000,
            .base_23_16 = 0x00,
            .type = DESC_TYPE_READ_WRITE,
            .s = DESC_CODE_DATA,
            .dpl = 0x00,
            .p = 0x01,
            .limit_19_16 = GDT_LIMIT_4KIB(FLAT_SEGM_SIZE) >> 16,
            .avl = 0x0,
            .l = 0x0,
            .db = 0x0,
            .g = 0x01,
            .base_31_24 = 0x00,
        },
        [GDT_IDX_DATA_3] =
        {
            // El descriptor nulo es el primero que debemos definir siempre
            // Cada campo del struct se matchea con el formato que figura en el manual de intel
            // Es una entrada en la GDT.
            .limit_15_0 = GDT_LIMIT_4KIB(FLAT_SEGM_SIZE) & (0x0000FFFF),
            .base_15_0 = 0x0000,
            .base_23_16 = 0x00,
            .type = DESC_TYPE_READ_WRITE,
            .s = DESC_CODE_DATA,
            .dpl = 0x03,
            .p = 0x01,
            .limit_19_16 = GDT_LIMIT_4KIB(FLAT_SEGM_SIZE) >> 16,
            .avl = 0x0,
            .l = 0x0,
            .db = 0x0,
            .g = 0x01,
            .base_31_24 = 0x00,
        },
    
};

// Aca hay una inicializacion estatica de una structura que tiene su primer componente el tamano 
// y en la segunda, la direccion de memoria de la GDT. Observen la notacion que usa. 
gdt_descriptor_t GDT_DESC = {sizeof(gdt) - 1, (uint32_t)&gdt};
