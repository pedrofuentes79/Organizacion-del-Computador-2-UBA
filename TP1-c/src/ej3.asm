section .rodata
; Poner acá todas las máscaras y coeficientes que necesiten para el filtro
mask_shuf: db 0x00, 0x80, 0x80, 0x80, 0x01, 0x80, 0x80, 0x80, 0x02, 0x80, 0x80, 0x80, 0x03, 0x80, 0x80, 0x80

section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 3A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej3a
global EJERCICIO_3A_HECHO
EJERCICIO_3A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Dada una imagen origen escribe en el destino `scale * px + offset` por cada
; píxel en la imagen.
;
; Parámetros:
;   - dst_depth[rdi]: La imagen destino (mapa de profundidad). Está en escala de
;                grises a 32 bits con signo por canal.
;   - src_depth[rsi]: La imagen origen (mapa de profundidad). Está en escala de
;                grises a 8 bits sin signo por canal.
;   - scale[edx]:     El factor de escala. Es un entero con signo de 32 bits.
;                Multiplica a cada pixel de la entrada.
;   - offset[ecx]:    El factor de corrimiento. Es un entero con signo de 32 bits.
;                Se suma a todos los píxeles luego de escalarlos.
;   - width[r8]:     El ancho en píxeles de `src_depth` y `dst_depth`.
;   - height[r9]:    El alto en píxeles de `src_depth` y `dst_depth`.
global ej3a
ej3a:
	push rbp
	mov rbp, rsp

	imul r9, r8
	shr r9, 2 
	xor r8, r8

	movdqu xmm1, [mask_shuf]

	; scale
	movd xmm2, edx
	pshufd xmm2, xmm2, 0x00_00_00_00

	; xmm2 = [scale | scale | scale | scale]

	; offset
	movd xmm3, ecx
	pshufd xmm3, xmm3, 0x00_00_00_00
	; xmm2 = [offset | offset | offset | offset]

	; iteracion
	.loop:
		cmp r8, r9
		je .fin

		mov r10d, [rsi] ; cargo 4 pixeles de src_depth
		movd xmm0, r10d

		;         0F 0E 0D 0C
		; xmm0 = [ basura | basura | basura | p0 p1 p2 p3 ]
		
		pshufb xmm0, xmm1

		; xmm0 = [0 0 0 p0 | 0 0 0 p1 | 0 0 0 p2 | 0 0 0 p3]

		; multiplico por scale
		pmulld xmm0, xmm2

		; sumo offset
		paddd xmm0, xmm3
		
		movdqu [rdi], xmm0 ; guardo los 4 pixeles en dst_depth

		add rsi, 4
		add rdi, 16
		add r8, 1
		jmp .loop
	
	.fin:
	pop rbp
	ret

; Marca el ejercicio 3B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej3b
global EJERCICIO_3B_HECHO
EJERCICIO_3B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Dadas dos imágenes de origen (`a` y `b`) en conjunto con sus mapas de
; profundidad escribe en el destino el pixel de menor profundidad por cada
; píxel de la imagen. En caso de empate se escribe el píxel de `b`.
;
; Parámetros:
;   - dst:     La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - a:       La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - depth_a: El mapa de profundidad de A. Está en escala de grises a 32 bits
;              con signo por canal.
;   - b:       La imagen origen B. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - depth_b: El mapa de profundidad de B. Está en escala de grises a 32 bits
;              con signo por canal.
;   - width:  El ancho en píxeles de todas las imágenes parámetro.
;   - height: El alto en píxeles de todas las imágenes parámetro.
global ej3b
ej3b:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; r/m64 = rgba_t*  dst[rdi]
	; r/m64 = rgba_t*  a[rsi]
	; r/m64 = int32_t* depth_a[rdx]
	; r/m64 = rgba_t*  b[rcx]
	; r/m64 = int32_t* depth_b[r8]
	; r/m32 = int      width[r9d]
	; r/m32 = int      height[r10d por pila]

	push rbp
	mov rbp, rsp

	mov r10d, [rbp+16]


	; contador de iteraciones necesarias [r9] = totalPixeles / pixelPorIteracion = width * height / 4
	; 16 bytes por iteracion y 4 bytes por pixel --> 4 pixeles por iteracion 
	imul r9d, r10d
	shr r9d, 2
	xor r10, r10


	; iteracion
	.loop:
		cmp r10, r9
		je .fin

		movdqu xmm0, [rsi] ; cargo 4 pixeles de la imagen a
		; xmm0 = [p1, p2, p3, p4]
		movdqu xmm1, [rdx] ; cargo 4 valores de depth_a (su mapa)

		movdqu xmm2, [rcx] ; cargo 4 pixeles de la imagen b
		; xmm2 = [p1', p2', p3', p4']
		movdqu xmm3, [r8] ; cargo 4 valores de depth_b (su mapa)

		;puedo comparar directamente los pixeles porque tienen la misma cantidad de bits

		pcmpgtd xmm3, xmm1  ;si son iguales me hay 0 y me quedo con la de b 
		pand xmm0, xmm3		; dejo pasar en xmm0 solo los pixeles de a que van
		pandn xmm3, xmm2	; dejo pasar los pixeles de b que si van
		por xmm0, xmm3      

		movdqu [rdi], xmm0 ; guardo los 4 pixeles en dst
		add rsi, 16
		add rcx, 16
		add rdx, 16
		add r8, 16
		add rdi, 16
		add r10, 1
		jmp .loop

		.fin:
			pop rbp
			ret
