section .rodata ; Poner acá todas las máscaras y coeficientes que necesiten para el filtro
	; mascaras para aplicar el filtro
	mask_red:  dq 0x00FF0000, 0x00FF0000, 0x00FF0000, 0x00FF0000
    mask_green: dq 0x0000FF00, 0x0000FF00, 0x0000FF00, 0x0000FF00
    mask_blue:  dq 0x000000FF, 0x000000FF, 0x000000FF, 0x000000FF
	mask_alpha: dq 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000

	; coeficientes para el filtro (calculo luminosidad)
    coef_red:  dq 0.2126, 0.2126, 0.2126, 0.2126
    coef_green: dq 0.7152, 0.7152, 0.7152, 0.7152
    coef_blue:  dq 0.0722, 0.0722, 0.0722, 0.0722

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
;   - dst [rdi]:    La imagen destino. Está a color (RGBA) en 8 bits sin signo por canal. 
;   - src [rsi]:    La imagen origen A. Está a color (RGBA) en 8 bits sin signo por canal.
;   - width [rdx]:  El ancho en píxeles de `src` y `dst`.
;   - height [rcx]: El alto en píxeles de `src` y `dst`.
global ej1
ej1: ; rdi = dst, rsi = src, rdx = width, rcx = height
	; prologo
	push rbp
	mov rbp, rsp

	; contador de iteraciones necesarias [rcx] = totalPixeles / pixelPorIteracion = width * height / 4
	; 16 bytes por iteracion y 4 bytes por pixel --> 4 pixeles por iteracion 
	mov rax, rdx
	imul rax, rcx	; rax = width * height
	shr rax, 2		; rax = rax / 4
	mov rcx, rax	; rcx = rax = #iteraciones

	; cargo en xmm8 los bytes de luminosidad
    movdqu xmm1, [coef_red]
    movdqu xmm2, [coef_green]
    movdqu xmm3, [coef_blue]

	; loop principal
	.ciclo: 
		; cargo los primeros 4 píxeles en xmm0
		movdqu xmm0, [rsi]	    ; xmm0 = | (a1,r1,g1,b1) | (a2,r2,g2,b2) | ... | ... |

		; componente roja
		movdqa xmm4, xmm0 
		pand xmm4, [mask_red]   ; xmm4 = | (0,r1,0,0) | (0,r2,0,0) | ... | ... | 
		psrld xmm4, 16  	    ; xmm4 = | (0,0,0,r1) | (0,0,0,r2) | ... | ... |

		; componente verde
		movdqa xmm5, xmm0
		pand xmm5, [mask_green] ; xmm5 = | (0,0,g1,0) | (0,0,g2,0) | ... | ... |
		psrld xmm5, 8           ; xmm5 = | (0,0,0,g1) | (0,0,0,g2) | ... | ... |

		; componente azul
		movdqa xmm6, xmm0
		pand xmm6, [mask_blue]  ; xmm6 = | (0,0,0,b1) | (0,0,0,b2) | ... | ... |

		; convertimos a flotante para multiplicar por los coeficientes float
		cvtdq2ps xmm4, xmm4
		cvtdq2ps xmm5, xmm5
		cvtdq2ps xmm6, xmm6

		; multiplicamos por los coeficientes
		mulps xmm4, xmm1 	   ; xmm4 = | (0,0,0,0.2126*r1) | (0,0,0,0.2126*r2) | ... | ... |
		mulps xmm5, xmm2	   ; xmm5 = | (0,0,0,0.7152*g1) | (0,0,0,0.7152*g2) | ... | ... |
		mulps xmm6, xmm3	   ; xmm6 = | (0,0,0,0.0722*b1) | (0,0,0,0.0722*b2) | ... | ... |

		; sumamos los resultados
		addps xmm4, xmm5 	   ; xmm4 = | (0,0,0,0.2126*r1+0.7152*g1)           | (0,0,0,0.2126*r2+0.7152*g2) 	        | ... | ... |
		addps xmm4, xmm6	   ; xmm4 = | (0,0,0,0.2126*r1+0.7152*g1+0.0722*b1) | (0,0,0,0.2126*r2+0.7152*g2+0.0722*b2) | ... | ... |

		; convertimos a entero 
		cvttps2dq xmm4, xmm4   ; xmm4 = | (0,0,0,lum1) | (0,0,0,lum2) | ... | ... |

        ; copio los valores de luminosidad en los 4 canales de los 4 pixeles
        pshufd xmm4, xmm4, 0   ; xmm4 = | (lum1,lum1,lum1,lum1) | (lum2,lum2,lum2,lum2) | ... | ... |

		; agrego el canal alpha
		por xmm4, [mask_alpha] ; xmm4 = | (255,lum1,lum1,lum1) | (255,lum2,lum2,lum2) | ... | ... |

		; guardo los 4 pixeles en dst
		movdqu [rdi], xmm4

		; avanzo a los siguientes 4 pixeles de src y dst
		add rdi, 16
		add rsi, 16
		loop .ciclo

	; epilogo
	pop rbp
	ret