section .rodata
; Poner acá todas las máscaras y coeficientes que necesiten para el filtro
	mask_alph: times 4 dd 0xFF_00_00_00
	mask_coef_blue:  times 4 dd 0x00_FF_00_00
	mask_coef_green: times 4 dd 0x00_00_FF_00
	mask_coef_red:   times 4 dd 0x00_00_00_FF

	mask_pedro1: db 0x80, 0x80, 0x80, 0x0E, 0x80, 0x0D, 0x80, 0x0C, 0x80, 0x80, 0x80, 0x0A, 0x80, 0x09, 0x80, 0x08
	mask_pedro2: db 0x80, 0x80, 0x80, 0x06, 0x80, 0x05, 0x80, 0x04, 0x80, 0x80, 0x80, 0x02, 0x80, 0x01, 0x80, 0x00
section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 2 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej1
global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

; Aplica un efecto de "mapa de calor" sobre una imagen dada (`src`). Escribe la
; imagen resultante en el canvas proporcionado (`dst`).
;
; Para calcular el mapa de calor lo primero que hay que hacer es computar la
; "temperatura" del pixel en cuestión:
; ```
; temperatura = (rojo + verde + azul) / 3
; ```
;
; Cada canal del resultado tiene la siguiente forma:
; ```
; |          ____________________
; |         /                    \
; |        /                      \        Y = intensidad
; | ______/                        \______
; |
; +---------------------------------------
;              X = temperatura
; ```
;
; Para calcular esta función se utiliza la siguiente expresión:
; ```
; f(x) = min(255, max(0, 384 - 4 * |x - 192|))
; ```
;
; Cada canal esta offseteado de distinta forma sobre el eje X, por lo que los
; píxeles resultantes son:
; ```
; temperatura  = (rojo + verde + azul) / 3
; salida.rojo  = f(temperatura)
; salida.verde = f(temperatura + 64)
; salida.azul  = f(temperatura + 128)
; salida.alfa  = 255
; ```
;
; Parámetros:
;   - dst:    La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - src:    La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - width:  El ancho en píxeles de `src` y `dst`.
;   - height: El alto en píxeles de `src` y `dst`.
global ej2
ej2:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; r/m64 = rgba_t*  dst
	; r/m64 = rgba_t*  src
	; r/m32 = uint32_t width
	; r/m32 = uint32_t height

	;prologo
	push rbp
	mov rbp, rsp

	; contador de iteraciones necesarias [r9] = totalPixeles / pixelPorIteracion = width * height / 4
	; 16 bytes por iteracion y 4 bytes por pixel --> 4 pixeles por iteracion 
	xor r8, r8 
	mov r9, rdx 
	imul r9, rcx
	shr r9, 2 

	; guardamos las máscaras usadas en registros xmm
	movdqu xmm12, [mask_alph]
	movdqu xmm8, [mask_coef_red]
	movdqu xmm9, [mask_coef_green]
	movdqu xmm10, [mask_coef_blue]

	.loop:
		cmp r8, r9
		je .fin

		movdqu xmm4, [rsi] ; leo 4 pixeles de src (1 pixel = 4 bytes)
		; xmm4 = a0 b0 g0 r0 | a1 b1 g1 r1 | a2 b2 g2 r2 | a3 b3 g3 r3

		; copiamos el dato para operarlo
		movdqu xmm5, xmm4

		; saco el primer byte de cada pixel 
		pandn xmm5, xmm12 	



		; asumo que tengo en xmm5 = 00_0b0_0g0_0r0 | 00_0b1_0g1_0r1
		; asumo que tengo en xmm6 = 00_0b2_0g2_0r2 | 00_0b3_0g3_0r3

		phaddw xmm5, xmm5 ; xmm5 = 00
		phaddw xmm6, xmm6 ; 
		;
		phaddd xmm6, xmm5
		; xmm6 = t0 t1 t2 t3
		



		; escribo los 4 pixeles en dst
		movdqu [rdi], xmm5 
		
		; avanzo 4 pixeles en los punteros a memoria (16 bytes)
		add rsi, 16
		add rdi, 16

		; avanzo el contador de iteraciones
		add r8, 1
		jmp .loop
 
	.fin:
		pop rbp
		ret


