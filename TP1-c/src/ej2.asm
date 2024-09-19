
section .rodata
	mask_blue:  times 4 dd 0x00_FF_00_00
	mask_green: times 4 dd 0x00_00_FF_00
	mask_red:   times 4 dd 0x00_00_00_FF
	mask_alpha: times 4 dd 0xFF_00_00_00

	align 16
	mask_3: times 4 dd 3.0

	align 16
	mask_4: times 4 dd 4.0

	align 16
	mask_192: times 8 dw 192

	align 16
	mask_384: times 8 dw 384

	align 16
	mask_offset: times 2 dw 0, 128, 64, 0

	align 16
	abs_mask dd 0x7FFFFFFF, 0x7FFFFFFF, 0x7FFFFFFF, 0x7FFFFFFF 

	align 16
	mask_sign: times 2 dq 0x8000800080008000

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
	movaps xmm13, [abs_mask]
	movdqu xmm10, [mask_4]
	movdqu xmm11, [mask_3]
	movdqu xmm14, [mask_192]

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
		divps xmm1, xmm11
		cvttps2dq xmm1, xmm1 

		;pasaje a 8 bits
		packusdw xmm1, xmm1
		;xmm1 = t1 | t1 | t1 | t1 | t2 | t2 | t2 | t2 | t3 | t3 | t3 | t3 | t4 | t4 | t4 | t4

		;copia y pasaje a 2 registros (uno para t1 y t2, y otro para t3 y t4) 
		;la idea es que cada registro tenga 2 pixeles y cada pixel los 4 colores con la temperatura
		movdqa xmm4, xmm1
		movdqa xmm5, xmm1
		pshuflw xmm4, xmm4, 0b00000000  ; Shuffle low words: t1 | t1 | t1 | t1
		pshufhw xmm4, xmm4, 0b01010101  ; Shuffle high words: t2 | t2 | t2 | t2
		pshuflw xmm5, xmm5, 0b10101010  ; Shuffle low words: t3 | t3 | t3 | t3
		pshufhw xmm5, xmm5, 0b11111111  ; Shuffle high words: t4 | t4 | t4 | t4

		;cada t_i es una word (16bits)
		;xmm4 = t1 | t1 | t1 | t1 | t2 | t2 | t2 | t2 | t2
		;xmm5 = t3 | t3 | t3 | t3 | t4 | t4 | t4 | t4 | t4

		;sumamos en cada byte correspondiente segun color (+64, +128)
		addps xmm4, [mask_offset]
		addps xmm5, [mask_offset]

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
		;-4*(abs(x-192))
		pxor xmm4, [mask_sign]
		pxor xmm5, [mask_sign]
		;384 - 4*(abs(x-192))
		addps xmm4, [mask_384]
		addps xmm5, [mask_384]
		;max(0, 384 - 4*(abs(x-192)))
		pmaxsw xmm4, xmm10
		pmaxsw xmm5, xmm10

		;saturamos y convertimos a 8 bits
		packuswb xmm4, xmm5 
		;xmm4 = f(t1) | f(t1) | f(t1) | f(t1) | f(t2) | f(t2) | f(t2) | f(t2) | f(t2) |
		;       f(t3) | f(t3) | f(t3) | f(t3) | f(t4) | f(t4) | f(t4) | f(t4) | f(t4)
		;cada t_i es un byte (8bits)

		;pegamos el alpha=255
		por xmm4, xmm12

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