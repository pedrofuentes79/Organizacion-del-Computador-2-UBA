section .rodata
; Poner acá todas las máscaras y coeficientes que necesiten para el filtro
; coeficientes escala de grises
mask_blue:  times 4 dd 0x00_FF_00_00
mask_green: times 4 dd 0x00_00_FF_00
mask_red: times 4 dd 0x00_00_00_FF

red times 4 dd 0.2126
green times 4 dd 0.7152
blue times 4 dd 0.0722
alpha: times 4 dd 0x00_00_00_FF
; asi es como veo la mascara. La escribo abajo 'al reves' porque asi se guarda en memoria. Fuck little endian.
; mask_shuf db 0x0F, 0x0B, 0x07, 0x03, 0x0E, 0x0A, 0x06, 0x02, 0x0D, 0x09, 0x05, 0x01, 0x0C, 0x08, 0x04, 0x00

mask_shuf db 0x00, 0x04, 0x08, 0x0C, 0x01, 0x05, 0x09, 0x0D, 0x02, 0x06, 0x0A, 0x0E, 0x03, 0x07, 0x0B, 0x0F


section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej1
global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Convierte una imagen dada (`src`) a escala de grises y la escribe en el
; canvas proporcionado (`dst`).
;
; Para convertir un píxel a escala de grises alcanza con realizar el siguiente
; cálculo:
; ```
; luminosidad = 0.2126 * rojo + 0.7152 * verde + 0.0722 * azul 
; ```
;
; Como los píxeles de las imágenes son RGB entonces el píxel destino será
; ```
; rojo  = luminosidad
; verde = luminosidad
; azul  = luminosidad
; alfa  = 255
; ```
;
; Parámetros:
;   - dst:    La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - src:    La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - width:  El ancho en píxeles de `src` y `dst`.
;   - height: El alto en píxeles de `src` y `dst`.
global ej1
ej1:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; rdi = rgba_t*  dst
	; rsi = rgba_t*  src
	; rdx = uint32_t width
	; rcx = uint32_t height

	push rbp
	mov rbp, rsp

	sub rsp, 16*4 ; guardo 16*4 bytes para 3 xmm
	movaps [rbp-16], xmm8
	movaps [rbp-32], xmm9
	movaps [rbp-48], xmm10
	movaps [rbp-64], xmm11


	movdqu xmm0, [red]
	movdqu xmm1, [green]
	movdqu xmm2, [blue]
	movdqu xmm3, [alpha]
	

	movdqu xmm8, [mask_red]
	movdqu xmm9, [mask_green]
	movdqu xmm10, [mask_blue]
	movdqu xmm11, [mask_shuf]


	xor r8, r8 ; contador de pixeles vistos

	; pixeles por ver
	mov r9, rdx
	imul r9, rcx
	shr r9, 2 ; divido por 4 (4 pixeles por iteracion)

	.loop:
		cmp r8, r9
		je .fin

		movdqu xmm4, [rsi] ; leo 4 pixeles de src
	

		; parte roja
		movdqa xmm5, xmm4
		pand xmm5, xmm8
		; no shifteo pues ya esta en la posicion correcta. xmm5: |a0 b0 g0 r0|...
		cvtdq2ps xmm5, xmm5 ; packed doubleword 2 packed single. osea, convierto de integer a float. es doubleword porque quedo 00_00_00_RR, 32 bits.
		mulps xmm5, xmm0    ; multiplico por el coeficiente
		cvtps2dq xmm5, xmm5 ; packed single 2 packed SIGNED doubleword integer. osea, convierto de float a integer. TRUNCO?

		; parte verde
		movdqa xmm6, xmm4
		pand xmm6, xmm9
		psrld xmm6, 8 ; desplazo 8 bits a la derecha 
		cvtdq2ps xmm6, xmm6
		mulps xmm6, xmm1
		cvtps2dq xmm6, xmm6

		; parte azul (se podria no usar xmm7 y pisar directo el xmm4...)
		movdqa xmm7, xmm4
		pand xmm7, xmm10
		psrld xmm7, 16 ; desplazo 24 bits a la derecha
		cvtdq2ps xmm7, xmm7
		mulps xmm7, xmm2
		cvtps2dq xmm7, xmm7

		; empaqueto para armar el pixel

		packusdw xmm5, xmm6
		; xmm5 = g3 g2 g1 g0 r3 r2 r1 r0 (16 bits each)

		packusdw xmm7, xmm3
		; xmm7 = a3 a2 a1 a0 b3 b2 b1 b0 (16 bits each)

		packuswb xmm5, xmm7
		; xmm5 = a3 a2 a1 a0 b3 b2 b1 b0 g3 g2 g1 g0 r3 r2 r1 r0 (8 bits each)

		; reordenar con shuf
		pshufb xmm5, xmm11

		movdqu [rdi], xmm5 ; guardo el pixel en dst
		
		; avanzo 4 pixeles en los punteros a memoria (16 bytes)
		add rsi, 16
		add rdi, 16

		; avanzo el contador de iteraciones
		add r8, 1
		jmp .loop
 
	.fin:
		movaps xmm8, [rbp-16]  ; Restaura xmm8
		movaps xmm9, [rbp-32]  ; Restaura xmm9
		movaps xmm10, [rbp-48] ; Restaura xmm10
		add rsp, 64
		pop rbp
		ret

