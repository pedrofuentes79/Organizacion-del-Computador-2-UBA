section .rodata
; Poner acá todas las máscaras y coeficientes que necesiten para el filtro
	mask_alph: times 4 dd 0xFF_00_00_00
	mask_green: times 4 dd 0x00_00_40_00
	mask_blue: times 4 dd 0x00_80_00_00
	
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
EJERCICIO_3A_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

; Dada una imagen origen escribe en el destino `scale * px + offset` por cada
; píxel en la imagen.
;
; Parámetros:
;   - dst_depth: La imagen destino (mapa de profundidad). Está en escala de
;                grises a 32 bits con signo por canal.
;   - src_depth: La imagen origen (mapa de profundidad). Está en escala de
;                grises a 8 bits sin signo por canal.
;   - scale:     El factor de escala. Es un entero con signo de 32 bits.
;                Multiplica a cada pixel de la entrada.
;   - offset:    El factor de corrimiento. Es un entero con signo de 32 bits.
;                Se suma a todos los píxeles luego de escalarlos.
;   - width:     El ancho en píxeles de `src_depth` y `dst_depth`.
;   - height:    El alto en píxeles de `src_depth` y `dst_depth`.
global ej3a
ej3a:
	push rbp
	mov rbp, rsp

	; contador de iteraciones necesarias [r9] = totalPixeles / pixelPorIteracion = width * height / 4
	; 16 bytes por iteracion y 4 bytes por pixel --> 4 pixeles por iteracion 
	xor r8, r8 
	mov r9, rdx 
	imul r9, rcx
	shr r9, 2

	; guardo los valores de scale y offset en registros
	movd xmm4, esi
	movd xmm5, edi
	punpckldq xmm4, xmm4
	punpckldq xmm5, xmm5

	; iteracion
	.loop:
		cmp r8, r9
		je .fin

		movdqu xmm0, [rsi] ; cargo 4 pixeles de src_depth
		; xmm0 = [p1, p2, p3, p4]

		; desempaqueto los pixeles
		movdqa xmm6, xmm0
		punpcklbw xmm6, xmm6
		; xmm6 = [a1,a1,g1,g1,b1,b1,r1,r1,a2,a2,g2,g2,b2,b2,r2,r2]

		movdqa xmm7, xmm0
		punpckhbw xmm7, xmm7
		; xmm7 = [a3,a3,g3,g3,b3,b3,r3,r3,a4,a4,g4,g4,b4,b4,r4,r4]

		; multiplico por scale
		pmullw xmm6, xmm4
		pmullw xmm7, xmm4

		; sumo offset
		paddw xmm6, xmm5
		paddw xmm7, xmm5

		; saturacion
		packuswb xmm6, xmm6
		packuswb xmm7, xmm7

		; empaqueto los pixeles
		movdqa xmm0, xmm6
		packuswb xmm0, xmm7

		movdqu [rdi], xmm0 ; guardo los 4 pixeles en dst_depth

		add rsi, 16
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
EJERCICIO_3B_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

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
	; r/m64 = rgba_t*  dst
	; r/m64 = rgba_t*  a
	; r/m64 = int32_t* depth_a
	; r/m64 = rgba_t*  b
	; r/m64 = int32_t* depth_b
	; r/m32 = int      width
	; r/m32 = int      height

	push rbp
	mov rbp, rsp

	; contador de iteraciones necesarias [r9] = totalPixeles / pixelPorIteracion = width * height / 4
	; 16 bytes por iteracion y 4 bytes por pixel --> 4 pixeles por iteracion 
	xor r8, r8 
	mov r9, rdx 
	imul r9, rcx
	shr r9, 2


	; guardo los valores de scale y offset en registros
	movd xmm4, esi
	movd xmm5, edi
	punpckldq xmm4, xmm4
	punpckldq xmm5, xmm5

	; iteracion
	.loop:
		cmp r8, r9
		je .fin

		movdqu xmm0, [rsi] ; cargo 4 pixeles de la imagen a
		; xmm0 = [p1, p2, p3, p4]
		movdqu xmm1, [rdx] ; cargo 4 pixeles de depth_a (su mapa)

		movdqu xmm2, [r8] ; cargo 4 pixeles de la imagen b
		; xmm2 = [p1', p2', p3', p4']
		movdqu xmm3, [r9] ; cargo 4 pixeles de depth_b (su mapa)

		;puedo comparar directamente los pixeles porque tienen la misma cantidad de bits
		pcmpgtd xmm3, xmm1  ;si son iguales me hay 0 y me quedo con la de b 
		pand xmm0, xmm3
		pandn xmm2, xmm3
		por xmm0, xmm2 ;en xmm8 tengo los pixeles que me quedo
		; ej xmm0= [p1, p2', p3, p4]

		movdqu [rdi], xmm0 ; guardo los 4 pixeles en dst
		add rsi, 16
		add rdi, 16

		add r8,1 
		jmp .loop

	    ; hago esto comentado porque me parecee que no es necesario pero lo dejo por si es que si asi no lo tienen que hacer de vuelta
		/* ;desempaqueto los pixeles para poder comparar p1 con p1' y p2 con p2' y asi
		movdqa xmm6, xmm0
		punpcklbw xmm6, xmm6
		; xmm6 = [a1,a1,g1,g1,b1,b1,r1,r1,a2,a2,g2,g2,b2,b2,r2,r2] de a

		movdqa xmm7, xmm2
		punpcklbw xmm7, xmm7
		; xmm7 = [a1,a1,g1,g1,b1,b1,r1,r1,a2,a2,g2,g2,b2,b2,r2,r2] de b

		; comparo las profundidades y me quedo con la menor (en caso de empate me quedo con la de b)
		pcmpgtd xmm3, xmm1  ;si son iguales me hay 0 y me quedo con la de b 
		pand xmm8, xmm6
		pandn xmm3, xmm7
		por xmm8, xmm3 ;en xmm8 tengo los pixeles que me quedo
		; ej xmm8= [a1',a1',g1',g1',b1',b1',r1',r1',a2,a2,g2,g2,b2,b2,r2,r2] de a

		;todavia me queda comparar p3 con p3' y p4 con p4'
		movdqa xmm6, xmm0
		punpckhbw xmm6, xmm6
		; xmm6 = [a3,a3,g3,g3,b3,b3,r3,r3,a4,a4,g4,g4,b4,b4,r4,r4] de a

		movdqa xmm7, xmm2
		punpckhbw xmm7, xmm7
		; xmm7 = [a3,a3,g3,g3,b3,b3,r3,r3,a4,a4,g4,g4,b4,b4,r4,r4] de b

		; comparo las profundidades y me quedo con la menor (en caso de empate me quedo con la de b)
		pcmpgtd xmm3, xmm1  ;si son iguales me hay 0 y me quedo con la de b
		pand xmm9, xmm6
		pandn xmm3, xmm7
		por xmm9, xmm3 ;en xmm9 tengo los pixeles que me quedo

		;empaqueto los pixeles
		movdqa xmm0, xmm8
		packuswb xmm0, xmm9 */

	.fin:
	pop rbp
	ret
