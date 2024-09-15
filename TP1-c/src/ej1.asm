section .rodata
; Poner acá todas las máscaras y coeficientes que necesiten para el filtro
; coeficientes escala de grises

	; mascaras para aplicar el filtro
	mask_coef_blue:  times 4 dd 0x00_FF_00_00
	mask_coef_green: times 4 dd 0x00_00_FF_00
	mask_coef_red:   times 4 dd 0x00_00_00_FF

	; coeficientes para el filtro (calculo luminosidad)
	coef_red: times 4 dd 0.2126
	coef_green: times 4 dd 0.7152
	coef_blue: times 4 dd 0.0722
	coef_alph: times 4 dd 0xFF_00_00_00

mask_shuf db 0x03, 0x03, 0x03, 0x03, 0x02, 0x02, 0x02, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00
mask_xor times 4 db 0xFF, 0x00, 0x00, 0x00

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

	;prologo
	push rbp
	mov rbp, rsp

	;guardamos memoria para los registros volatiles
	sub rsp, 16*5 
	movaps [rbp-16], xmm8
	movaps [rbp-32], xmm9
	movaps [rbp-48], xmm10
	movaps [rbp-64], xmm11
	movaps [rbp-80], xmm12

	;guardamos en registros los coeficientes y las máscaras para operar mejor
	movdqu xmm0, [coef_red]
	movdqu xmm1, [coef_green]
	movdqu xmm2, [coef_blue]
	movdqu xmm3, [coef_alph]
	movdqu xmm8, [mask_coef_red]
	movdqu xmm9, [mask_coef_green]
	movdqu xmm10, [mask_coef_blue]
	movdqu xmm11, [mask_shuf]
	movdqu xmm12, [mask_xor]

	; contador de iteraciones necesarias [r9] = totalPixeles / pixelPorIteracion = width * height / 4
	; 16 bytes por iteracion y 4 bytes por pixel --> 4 pixeles por iteracion 
	xor r8, r8 
	mov r9, rdx 
	imul r9, rcx
	shr r9, 2 

	.loop:
		cmp r8, r9
		je .fin

		movdqu xmm4, [rsi] ; leo 4 pixeles de src (1 pixel = 4 bytes)
		; xmm4 = a0 b0 g0 r0 | a1 b1 g1 r1 | a2 b2 g2 r2 | a3 b3 g3 r3
	
		; parte roja
		movdqa xmm5, xmm4	; xmm5 = xmm4
		pand xmm5, xmm8	    ; xmm5 = 00_00_00_rr | ...
		cvtdq2ps xmm5, xmm5 ; packed doubleword 2 packed single.
							; convierto de integer a float (es doubleword porque quedo 00_00_00_RR, 32 bits)
		mulps xmm5, xmm0    ; xmm5 = |(0,0,0,0.2126*r0)|(0,0,0,0.2126*r1)|

		; parte verde
		movdqa xmm6, xmm4	; xmm6 = xmm4
		pand xmm6, xmm9		; xmm6 = 00_00_gg_00 | ...
		psrld xmm6, 8 		; xmm6 = 00_00_00_gg | ...
		cvtdq2ps xmm6, xmm6 ; integer -> float
		mulps xmm6, xmm1 	; xmm6 = (0,0,0,0.7152*g0) | ... 

		; parte azul (se podria no usar xmm7 y pisar directo el xmm4...)
		movdqa xmm7, xmm4	; xmm7 = xmm4
		pand xmm7, xmm10	; xmm7 = 00_bb_00_00 | ...
		psrld xmm7, 16 		; xmm7 = 00_00_00_bb | ...
		cvtdq2ps xmm7, xmm7	; integer -> float
		mulps xmm7, xmm2	; xmm7 = (0,0,0,0.0722*b) | ...

		; xmm5 = (0,0,0,0.0722*b0+0.7152*g0+0.2126*r0) | ...
		; xmm5 = (0,0,0,lum0) | ...
		addps xmm5, xmm6
		addps xmm5, xmm7

		; xmm5 = lum0 | lum1 | ...
		cvtps2dq xmm5, xmm5 ; cada lum ocupa 32 bits (4 bytes)
		packusdw xmm5, xmm5 ; cada lum ocupa 16 bits (2 byte)
		packuswb xmm5, xmm5 ; cada lum ocupa 8 bits (1 byte)

		pshufb xmm5, xmm11
		por xmm5, xmm3
		; xmm5 = l3 l2 l1 l0 ... l3 l2 l1 l0 (1byte each)
		

		movdqu [rdi], xmm5 ; escribo los 4 pixeles en dst
		
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
		movaps xmm11, [rbp-64] ; Restaura xmm11
		movaps xmm12, [rbp-80] ; Restaura xmm12
		add rsp, 16*5
		pop rbp
		ret

