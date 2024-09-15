section .rodata
; Poner acá todas las máscaras y coeficientes que necesiten para el filtro
; coeficientes escala de grises
mask_green:  dd 0x00_FF_00_00, 0x00_FF_00_00, 0x00_FF_00_00, 0x00_FF_00_00
mask_blue: dd 0x00_00_FF_00, 0x00_00_FF_00, 0x00_00_FF_00, 0x00_00_FF_00
mask_alpha: dd 0x00_00_00_FF, 0x00_00_00_FF, 0x00_00_00_FF, 0x00_00_00_FF
mask_red: dd 0xFF_00_00_00, 0xFF_00_00_00, 0xFF_00_00_00, 0xFF_00_00_00


red dq 0.2126, 0.2126, 0.2126, 0.2126
green dq 0.7152, 0.7152, 0.7152, 0.7152
blue dq 0.0722, 0.0722, 0.0722, 0.0722
alpha dq 0xFF, 0xFF, 0xFF, 0xFF

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

	sub rsp, 48 ; guardo 16*3 bytes para 3 xmm
	movaps [rbp-16], xmm8
	movaps [rbp-32], xmm9
	movaps [rbp-48], xmm10


	movdqu xmm0, [red]
	movdqu xmm1, [green]
	movdqu xmm2, [blue]
	movdqu xmm3, [alpha]

	movdqu xmm8, [mask_red]
	movdqu xmm9, [mask_green]
	movdqu xmm10, [mask_blue]

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
		psrld xmm5, 24 ; desplazo 24 bits a la derecha ( asumo RGBA )
		pmovzxbd xmm5, xmm5 ; ahora, cada valor de rojo es de 32 bits pues tiene 0s adelante. quedan en floats :)

		; en la de arriba se podria haber usado pmovzxbd xmm5, xmm5 para convertir a 32 bits

		mulps xmm5, xmm0    ; multiplico por el coeficiente
		cvtps2dq xmm5, xmm5 ; packed single 2 packed SIGNED doubleword integer
		packuswb xmm5, xmm5 ; convierto a 8 bits


		; parte verde
		movdqa xmm6, xmm4
		pand xmm6, xmm9
		psrld xmm6, 16 ; desplazo 16 bits a la derecha ( asumo RGBA )
		pmovzxbd xmm6, xmm6
		mulps xmm6, xmm1
		cvtps2dq xmm6, xmm6
		packuswb xmm6, xmm6

		; parte azul
		movdqa xmm7, xmm4
		pand xmm7, xmm10
		psrld xmm7, 8 ; desplazo 8 bits a la derecha ( asumo RGBA )
		pmovzxbd xmm7, xmm7
		mulps xmm7, xmm2
		cvtps2dq xmm7, xmm7		; DUDA
		packuswb xmm7, xmm7		; DUDA

		; vuelvo a armar el pixel
		movdqa xmm4, xmm5
		por xmm4, xmm6
		por xmm4, xmm7
		por xmm4, xmm3

		movdqu [rdi], xmm4 ; guardo el pixel en dst
		
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
		add rsp, 48
		pop rbp
		ret

