section .rodata
; Poner acá todas las máscaras y coeficientes que necesiten para el filtro
	mask_alph: times 4 dd 0xFF_00_00_00
	mask_green: times 4 dd 0x00_00_40_00
	mask_blue: times 4 dd 0x00_80_00_00
	
	mask_pedro1: db 0x80, 0x80, 0x80, 0x0E, 0x80, 0x0D, 0x80, 0x0C, 0x80, 0x80, 0x80, 0x0A, 0x80, 0x09, 0x80, 0x08
	mask_pedro2: db 0x80, 0x80, 0x80, 0x06, 0x80, 0x05, 0x80, 0x04, 0x80, 0x80, 0x80, 0x02, 0x80, 0x01, 0x80, 0x00

	mask_shuf: db 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x02, 0x02, 0x02, 0x02, 0x03, 0x03, 0x03, 0x03
	reciprocal_3:  dq 0x5555555555555555, 0x5555555555555555 
	mask_192: times 16 db 192 
	mask_384: times 16 db 384

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
	movdqu xmm9, [mask_green]
	movdqu xmm8, [mask_blue]
	movdqu xmm7, [mask_192]
	movdqu xmm10, [mask_384]
	movdqu xmm11, [mask_shuf]

	.loop:
		cmp r8, r9
		je .fin

		movdqu xmm4, [rsi] ; leo 4 pixeles de src (1 pixel = 4 bytes)
		; xmm4 = a0 b0 g0 r0 | a1 b1 g1 r1 | a2 b2 g2 r2 | a3 b3 g3 r3

		; copiamos el dato para operarlo
		movdqu xmm5, xmm4
		movdqu xmm6, xmm4

		pshufb xmm5, xmm11 ; xmm5 = 0 0 0 b0 | 0 g0 0 r0 | 0 0 0 b1 | 0 g1 0 r1
		pshufb xmm6, xmm12 ; xmm6 = 0 0 0 b2 | 0 g2 0 r2 | 0 0 0 b3 | 0 g3 0 r3

		; realizamos las sumas horizontales
		phaddw xmm5, xmm5 ; xmm5 = b0+00 | g0+r0 | b1+00 | g1+r1
		phaddw xmm6, xmm6 ; xmm6 = b2+00 | g2+r2 | b3+00 | g3+r3
		phaddd xmm6, xmm5 ; xmm6 = b0+00+g0+r0  | b1+00+g1+r1 | b2+00+g2+r2 | b3+00+g3+r3
		; 							t1 (8 bits) | t2 (8 bits)  | t3 (8 bits)  | t4 (8 bits)

		; operacion de conversion ... ?? (saturamos) O sea las t1 

		; x = x / 3 
	    pmulld xmm6, [reciprocal_3] ; xmm6 = t1*(1/3) | t2*(1/3) | t3*(1/3) | t4*(1/3)
		psrld xmm6, 30 				; Deajustar la escala Q2.30 a entero

		; convertimos a t1 t1 t1 t1 | t2 t2 t2 t2 | t3 t3 t3 t3 | t4 t4 t4 t4
		pshufb xmm6, xmm11

		; x[green] += 64 (saturando) --> x = t1 t1 (t1+64) t1 | ... | ..
		paddusb xmm6, xmm9

		; x[azul] += 128
		paddusb xmm6, xmm8

		; aplicamos la funcion f(x) = min(255, max(0, 384 - 4 * |x - 192|))
		; cada byte de cada pixel es un x distinto
		
		; Revisar si se puede operar a nivel byte o si es pasar a 32bits y despues convertir a t1 t1 t1 t1 | t2 t2 t2 t2 | ...
		; xmm6 = |t1-192| | t1-192 | t1-192 | t1-192 | ...
		psubb xmm6, xmm7 ; Restar xmm7 de xmm6
		movdqa xmm0, xmm6 ; Copiar xmm6 a xmm0
		psignb xmm0, xmm6 ; Obtener el signo de cada byte en xmm6 y aplicarlo a xmm0
		pxor xmm6, xmm0   ; Invertir los bits de xmm6 si el byte es negativo
		psubb xmm6, xmm0  ; Restar el valor original para obtener el valor absoluto
		
		; xmm6 *= 4
		pslld xmm6, 2 		
		
		; suponemos que en xmm10 tenemos 384 en cada byte
		xor xmm0, xmm0 		; xmm7 = 0
		psubusb xmm10, xmm6 ; 384 - 4 * |x - 192|
		pmaxub xmm10, xmm0  ; max(0, xmm10)

		; pisamos el primer byte de cada pixel con alfa=0xFF
		por xmm6, [mask_alpha] ;

		; escribo los 4 pixeles en dst
		movdqu [rdi], xmm6 
		
		; avanzo 4 pixeles en los punteros a memoria (16 bytes)
		add rsi, 16
		add rdi, 16

		; avanzo el contador de iteraciones
		add r8, 1
		jmp .loop
 
	.fin:
		pop rbp
		ret


