
section .rodata

	mask_blue:  times 4 dd 0x00_FF_00_00
	mask_green: times 4 dd 0x00_00_FF_00
	mask_red:   times 4 dd 0x00_00_00_FF
	mask_alpha: times 4 dd 0xFF_00_00_00

	align 16
	mask_zero: times 8 dw 0

	align 16
	mask_3: times 4 dd 3.0

	align 16
	mask_4: times 4 dd 4.0

	align 16
	mask_192: times 8 dw 192

	align 16
	mask_384: times 8 dw 384

	align 16
	mask_255: times 8 dw 255

	align 16
	;						r  g   b  a 
	mask_offset: times 2 dw 0, 64, 128, 0

	align 16
	mask_abs dd 0x7FFFFFFF, 0x7FFFFFFF, 0x7FFFFFFF, 0x7FFFFFFF 

section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.
;
; Parámetros:
;   - dst:    La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - src:    La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - width:  El ancho en píxeles de `src` y `dst`.
;   - height: El alto en píxeles de `src` y `dst`.
global ej2
ej2: ; dst [rdi], src [rsi], width [rdx], height [rcx]
	;prologo
	push rbp
	mov rbp, rsp

	;contador
	xor r8, r8
	mov r9, rdx
	imul r9, rcx
	shr r9, 2	

	;masks/coefs
	movdqu xmm12, [mask_alpha]	
	movaps xmm13, [mask_abs]
	movdqu xmm14, [mask_384]

	.loop:
		;fin loop
		cmp r8, r9
		je .end

		;leemos pixeles src
		movdqu xmm0, [rsi]

		;calculo temperatura (queda en int)
		movdqu xmm1, xmm0
		pand xmm1, [mask_red]
		movdqu xmm2, xmm0
		pand xmm2, [mask_green]
		psrad xmm2, 8
		movdqu xmm3, xmm0
		pand xmm3, [mask_blue]
		psrad xmm3, 16
		paddd xmm1, xmm2
		paddd xmm1, xmm3
		cvtdq2ps xmm1, xmm1
		divps xmm1, [mask_3]
		cvttps2dq xmm1, xmm1 

		;pasaje a 16 bits
		packusdw xmm1, xmm1

		;replicamos 4 veces cada temperatura manteniendo los 16 bits
		;como nos falta espacio, usamos dos registros
		movdqa xmm4, xmm1
		movdqa xmm5, xmm1
		pshuflw xmm4, xmm4, 0b00000000  ; Shuffle low words: t1 | t1 | t1 | t1
		pshufhw xmm4, xmm4, 0b01010101  ; Shuffle high words: t2 | t2 | t2 | t2
		pshuflw xmm5, xmm5, 0b10101010  ; Shuffle low words: t3 | t3 | t3 | t3
		pshufhw xmm5, xmm5, 0b11111111  ; Shuffle high words: t4 | t4 | t4 | t4

		;cada t_i es una word (16bits)
		;xmm4 = t1 | t1 | t1 | t1 | t2 | t2 | t2 | t2 | t2
		;xmm5 = t3 | t3 | t3 | t3 | t4 | t4 | t4 | t4 | t4

		;sumamos en cada word el offset para el calculo (a:0, b:128, g:64, r:0)
		paddw xmm4, [mask_offset]
		paddw xmm5, [mask_offset]

		;aplicamos la funcion
		;x-192
		psubw xmm4, [mask_192]
		psubw xmm5, [mask_192]
		;abs(x-192)
		pabsw xmm4, xmm4
		pabsw xmm5, xmm5
		;4*(abs(x-192))
		psllw xmm4, 2
		psllw xmm5, 2
		;384 - 4*(abs(x-192))
		movdqu xmm15, xmm14 ; xmm15 = 384
		movdqu xmm11, xmm14 ; xmm15 = 384
		psubw xmm15, xmm4   ; xmm15 = 384 - 4*(abs(x-192))
		psubw xmm11, xmm5	; xmm14 = 384 - 4*(abs(x-192))
		movdqu xmm4, xmm15
		movdqu xmm5, xmm11
		;max(0, 384 - 4*(abs(x-192)))
		pmaxsw xmm4, [mask_zero]
		pmaxsw xmm5, [mask_zero]

		;min(255, max(0, 384 - 4*(abs(x-192)))
		;esto capaz no hace falta
        pminsw xmm4, [mask_255]
        pminsw xmm5, [mask_255]

		;saturamos y convertimos a 8 bits
		packuswb xmm4, xmm5 
		;xmm4 = f(t1) | f(t1) | f(t1) | f(t1) | f(t2) | f(t2) | f(t2) | f(t2) | f(t2) |
		;       f(t3) | f(t3) | f(t3) | f(t3) | f(t4) | f(t4) | f(t4) | f(t4) | f(t4)
		;cada t_i es un byte (8bits)

		;pegamos el alpha=255
		por xmm4, [mask_alpha]

		;cargamos pixeles en dst
		movdqu [rdi], xmm4

		;iterador
		add r8, 1
		add rdi, 16
		add rsi, 16
		jmp .loop

	;epilogo
	.end:
		pop rbp
		ret