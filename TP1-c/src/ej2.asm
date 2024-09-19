section .rodata
; Poner acá todas las máscaras y coeficientes que necesiten para el filtro
	;mask_pedro2: dq 0x80_0D_80_0C_80_80_80_0E, 0x80_09_80_08_80_80_80_0A
					; p0                       ; p1	
	; mask_pedro1: dq 0x04_80_05_80_06_80_80_80, 0x00_80_01_80_02_80_80_80
	; mask_pedro2: dq 0x0C_80_0D_80_0E_80_80_80, 0x08_80_09_80_0A_80_80_80
	mask_pedro1: db 0x00, 0x80, 0x01, 0x80, 0x02, 0x80, 0x80, 0x80, 0x04, 0x80, 0x05, 0x80, 0x06, 0x80, 0x80, 0x80
	mask_pedro2: db 0x08, 0x80, 0x09, 0x80, 0x0A, 0x80, 0x80, 0x80, 0x0C, 0x80, 0x0D, 0x80, 0x0E, 0x80, 0x80, 0x80
	mask_shuf: db 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x02, 0x02, 0x02, 0x02, 0x03, 0x03, 0x03, 0x03
	reciprocal_3:  dq 0x5555555555555555, 0x5555555555555555
	mask_shuf1: db 0x08, 0x80, 0x08, 0x80, 0x08, 0x80, 0x80, 0x80, 0x0C, 0x80, 0x0C, 0x80, 0x0C, 0x80, 0x80, 0x80
	mask_shuf2: db 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x80, 0x80, 0x04, 0x80, 0x04, 0x80, 0x04, 0x80, 0x80, 0x80
	mask_resta: dw 192,128,64,0,192,128,64,0
	mask_384  : dw 384, 384, 384, 384, 384, 384, 384, 384
	three: times 4 dd 3.0
    mask_last1: dq 0x8080808080808080, 0x0F_0E_0D_0C_0B_0A_09_08
    mask_last2: dq 0x07_06_05_04_03_02_01_00, 0x8080808080808080
    mask_alpha: times 4 dd 0xFF_00_00_00
        
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
EJERCICIO_2_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

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
	movdqu xmm1, [three]
	movdqu xmm7, [mask_resta]
	movdqu xmm11, [mask_shuf1]
	movdqu xmm12, [mask_shuf2]
	movdqu xmm14, [mask_pedro1]
    movdqu xmm15, [mask_pedro2]
    movdqu xmm0, [mask_last1]
    movdqu xmm9, [mask_last2]


	.loop:
		cmp r8, r9
		je .fin

		movdqu xmm4, [rsi] ; leo 4 pixeles de src (1 pixel = 4 bytes)
		; xmm4 = a0 b0 g0 r0 | a1 b1 g1 r1 | a2 b2 g2 r2 | a3 b3 g3 r3

		movdqa xmm5, xmm4
		movdqa xmm6, xmm4
		; a0 b0 g0 r0

		pshufb xmm5, xmm14 
		pshufb xmm6, xmm15 
		; xmm5 = 0 0 0 b0 | 0 g0 0 r0 | 0 0 0 b1 | 0 g1 0 r1
		; xmm6 = 0 0 0 b2 | 0 g2 0 r2 | 0 0 0 b3 | 0 g3 0 r3

		; realizamos las sumas horizontales
		phaddw xmm5, xmm5 
		phaddw xmm6, xmm6 
		; xmm5 = b0+00 g0+r0 | b1+00 g1+r1 | b0+00  g0+r0 | b1+00 g1+r1
		; xmm6 = b3+00 g3+r3 | b2+00 g2+r2 | b3+00  g3+r3 | b2+00 g2+r2


		; paso a dword		 		32 bits each
		pxor xmm13, xmm13
		punpcklwd xmm5, xmm13 ; xmm5 = 00 b0 | 00 (g0+r0) | 00 b1 | 00 (g1+r1)  
		punpcklwd xmm6, xmm13 ; xmm6 = 00 b3 | 00 (g3+r3) | 00 b2 | 00 (g2+r2)

		phaddd xmm6, xmm5
		; 3t3 3t2 3t0 3t1

		;xmm6 = b3+00+g3+r3 | b2+00+g2+r2 | b0+00+g0+r0 | b1+00+g1+r1
		;      3t3 (32 b)  | 3t2 (32b)   | 3t0 (32b)   | 3t1 (32b)
		

		cvtdq2ps xmm6, xmm6 ; paso a float
		divps xmm6, xmm1    ; divido por 3 cada float ; se puede hacer roundps despues ?
		roundps xmm6, xmm6, 1 ; redondeo a entero
		cvtps2dq xmm6, xmm6 ; paso a int32 (es menor a 255)
		; xmm6 = t3 t2 t0 t1

		movdqa xmm2, xmm6 ; copio xmm6 a xmm2

		pshufb xmm2, xmm11 ; podria usar pshufd? (pero ya hice la mascara asi..)
		pshufb xmm6, xmm12
		; 0 0 0 t0 | 0 t0 0 t0 | 0 0 0 t1 | 0 t1 0 t1
		; 0 0 0 t3 | 0 t3 0 t3 | 0 0 0 t2 | 0 t2 0 t2

		; pero si lo miramos como 32 bits queda asi:

		; 0 t0 | t0 t0 | 0 t1 | t1 t1
		; 0 t3 | t3 t3 | 0 t2 | t2 t2

		psubw xmm6, xmm7
		psubw xmm2, xmm7
		; valor absoluto!
		pabsw xmm6, xmm6
		pabsw xmm2, xmm2

		; valores t+k-192, siendo k =0,64, 128
		; 0 t0 | t0 t0 | 0 t1 | t1 t1
		; 0 t3 | t3 t3 | 0 t2 | t2 t2

		; multiplico ambos por 4
		psllw xmm6, 2
		psllw xmm2, 2

		; resto (saturado, asi hace el max(0, 384-...))
		movdqu xmm3, [mask_384]
		movdqa xmm10, xmm3

		psubsw xmm3, xmm6
		psubsw xmm10, xmm2

		; convierto a 8 bits (asi hace el min(255,...))
		; pack unsigned (porque se que el numero es positivo) saturated (porque quiero min(255,..)) word (16bits) to byte (8 bits)
		packuswb xmm3, xmm3
		packuswb xmm10, xmm10
		; 		
		; xmm3 = __ b0 g0 r0 | __ b1 g1 r1 | __ b0 g0 r0 | __ b1 g1 r1
		; xmm10= __ b2 g2 r2 | __ b3 g3 r3 | __ b2 g2 r2 | __ b3 g3 r3

		pshufb xmm3, xmm0
		pshufb xmm10, xmm9

		; xmm3 = __ b0 g0 r0 | __ b1 g1 r1 | 00 00 00 00 | 00 00 00 00
		; xmm10= 00 00 00 00 | 00 00 00 00 | __ b2 g2 r2 | __ b3 g3 r3

		por xmm3, xmm10

		; xmm3 = __ b0 g0 r0 | __ b1 g1 r1 | __ b2 g2 r2 | __ b3 g3 r3

		movdqu xmm13, [mask_alpha]
		por xmm3, xmm13

		; xmm3 = FF b0 g0 r0 | FF b1 g1 r1 | FF b2 g2 r2 | FF b3 g3 r3

		; escribo los 4 pixeles en dst
		movdqu [rdi], xmm3
		
		; avanzo 4 pixeles en los punteros a memoria (16 bytes)
		add rsi, 16
		add rdi, 16

		; avanzo el contador de iteraciones
		add r8, 1
		jmp .loop
 
	.fin:
		pop rbp
		ret



