section .rodata

	; mascaras para aplicar el filtro
	mask_blue:  times 4 dd 0x00_FF_00_00
	mask_green: times 4 dd 0x00_00_FF_00
	mask_red:   times 4 dd 0x00_00_00_FF
	mask_alpha: times 4 dd 0xFF_00_00_00
	dest_mask: db 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x02, 0x02, 0x02, 0x02, 0x03, 0x03, 0x03, 0x03

	; coeficientes para el filtro (calculo luminosidad)
	coef_red: times 4 dd 0.2126
	coef_green: times 4 dd 0.7152
	coef_blue: times 4 dd 0.0722

section .text

FALSE EQU 0
TRUE  EQU 1

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
ej1: ; dst[rdi], src [rsi], width [rdx], height [rcx]

	;prologo
	push rbp
	mov rbp, rsp

	; r8 = 0
	xor r8, r8 	

	; r9 = width * height / 4
	mov r9, rdx 
	imul r9, rcx
	shr r9, 2

	; coefs/masks
	movdqu xmm6, [coef_blue]
	movdqu xmm5, [coef_green]
	movdqu xmm4, [coef_red]

	movdqu xmm15, [mask_blue]
	movdqu xmm14, [mask_green]
	movdqu xmm13, [mask_red]
	movdqu xmm12, [mask_alpha]

	movdqu xmm11, [dest_mask]

	.loop:
		; si r8 == r9 termino
		cmp r8, r9
		je .end

		; leo 4 pixeles de src
		movdqu xmm0, [rsi] ; a0 b0 g0 r0 | a1 b1 g1 r1 | a2 b2 g2 r2 | a3 b3 g3 r3
		
		; procesamiento

		;rojo
		movdqu xmm1, xmm0			; copia
		pand xmm1, xmm13	    	; 0x00_00_00_rr | 0x00_00_00_rr | 0x00_00_00_rr | 0x00_00_00_rr
		cvtdq2ps xmm1, xmm1         ; a float
		mulps xmm1, xmm4			; coef*rr       | coef*rr       | coef*rr       | coef*rr
		;verde
		movdqu xmm2, xmm0			; copia
		pand xmm2, xmm14			; 0x00_00_gg_00 | ...
		psrad xmm2, 8				; shift 8 bits = 1B
		cvtdq2ps xmm2, xmm2			; a float
		mulps xmm2, xmm5			; coef*gg       | coef*gg       | coef*gg       | coef*gg
		;azul
		movdqu xmm3, xmm0			; copia
		pand xmm3, xmm15			; 0x00_bb_00_00 | ...
		psrad xmm3, 16				; shift 16 bits = 2B
		cvtdq2ps xmm3, xmm3			; a float
		mulps xmm3, xmm6			; coef*bb       | coef*bb       | coef*bb       | coef*bb

		;sumamos los 3 canales (xmm1 = lum1 | lum2 | lum3 | lum4) 
		addps xmm1, xmm2
		addps xmm1, xmm3 			

		;convertimos suma a entero de 32 bits
		cvttps2dq xmm1, xmm1		

		;lo convertimos a 8 bits
		packusdw xmm1, xmm1
		packuswb xmm1, xmm1

		;tengo los lums de cada pixel en xmm1 como doblequadwords
		pshufb xmm1, xmm11	

		; alpha=255
		por xmm1, xmm12 

		; guardo en dst
		movdqu [rdi], xmm1

		; avanzo los punteros
		add rdi, 16
		add rsi, 16
		add r8, 1
		jmp .loop

	;epilogo
	.end:
		pop rbp
		ret
