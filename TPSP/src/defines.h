/* ** por compatibilidad se omiten tildes **
==============================================================================
TALLER System Programming - Arquitectura y Organizacion de Computadoras - FCEN
==============================================================================

  Definiciones globales del sistema.
*/

#ifndef __DEFINES_H__
#define __DEFINES_H__

/* Misc */
/* -------------------------------------------------------------------------- 
// Y Filas[GDT_IDX_CODE_3] =
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
        },------------- */
#define GDT_COUNT         35

#define GDT_IDX_NULL_DESC 0
#define GDT_IDX_CODE_0 1
#define GDT_IDX_CODE_3 2
#define GDT_IDX_DATA_0 3
#define GDT_IDX_DATA_3 4
#define GDT_IDX_VIDEO  5


/* Offsets en la gdt */
/* -------------------------------------------------------------------------- */
#define GDT_OFF_NULL_DESC (GDT_IDX_NULL_DESC << 3)
#define GDT_OFF_VIDEO  (GDT_IDX_VIDEO << 3)

/* COMPLETAR - Valores para los selectores de segmento de la GDT 
 * Definirlos a partir de los índices de la GDT, definidos más arriba 
 * Hint: usar operadores "<<" y "|" (shift y or) */

#define GDT_CODE_0_SEL (GDT_IDX_CODE_0 << 3) | 0x00
#define GDT_CODE_3_SEL (GDT_IDX_CODE_3 << 3) | 0x03
#define GDT_DATA_0_SEL (GDT_IDX_DATA_0 << 3) | 0x00
#define GDT_DATA_3_SEL (GDT_IDX_DATA_3 << 3) | 0x03


// Macros para trabajar con segmentos de la GDT.

// SEGM_LIMIT_4KIB es el limite de segmento visto como bloques de 4KIB
// principio del ultimo bloque direccionable.
#define GDT_LIMIT_4KIB(X)  (((X) / 4096) - 1)
#define GDT_LIMIT_BYTES(X) ((X)-1)

#define GDT_LIMIT_LOW(limit)  (uint16_t)(((uint32_t)(limit)) & 0x0000FFFF)
#define GDT_LIMIT_HIGH(limit) (uint8_t)((((uint32_t)(limit)) >> 16) & 0x0F)

#define GDT_BASE_LOW(base)  (uint16_t)(((uint32_t)(base)) & 0x0000FFFF)
#define GDT_BASE_MID(base)  (uint8_t)((((uint32_t)(base)) >> 16) & 0xFF)
#define GDT_BASE_HIGH(base) (uint8_t)((((uint32_t)(base)) >> 24) & 0xFF)

/* COMPLETAR - Valores de atributos */ 
#define DESC_CODE_DATA 0x01
#define DESC_SYSTEM    0x00
#define DESC_TYPE_EXECUTE_READ 0x0A
#define DESC_TYPE_READ_WRITE   0x02

/* COMPLETAR - Tamaños de segmentos */ 
#define FLAT_SEGM_SIZE 0x33100  // dudosoooo...
#define VIDEO_SEGM_SIZE 0xFFFFF // depende del tamano del buffer??


/* Direcciones de memoria */
/* -------------------------------------------------------------------------- */

// direccion fisica de comienzo del bootsector (copiado)
#define BOOTSECTOR 0x00001000
// direccion fisica de comienzo del kernel
#define KERNEL 0x00001200
// direccion fisica del buffer de video
#define VIDEO 0x000B8000


#endif //  __DEFINES_H__
