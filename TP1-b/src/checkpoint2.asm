extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_simplified
global alternate_sum_8
global product_2_f
global product_9_f
global alternate_sum_4_using_c

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4:
	push rbp ; alineado a 16
	mov rbp,rsp
	sub rdi, rsi ; x1 - x2
	add rdi, rdx ; x1 - x2 + x3
	sub rdi, rcx ; x1 - x2 + x3 - x4
	mov rax, rdi ; retorno en rax
	pop rbp
	ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4_using_c:
    ; prologo
    push rbp              
    mov rbp, rsp          

    ; Llamar a restar_c(x1, x2)
    call restar_c         ; rdi=x1, rsi=x2 ya están configurados
    mov r10, rax          ; guardar el resultado de x1 - x2 en r10 (uso r10 porque es uno no volatil!)

    ; Llamar a restar_c(x3, x4)
    mov rdi, rdx          ; configurar x3 en rdi
    mov rsi, rcx          ; configurar x4 en rsi
    call restar_c         ; llamar a restar_c(x3, x4)
    mov rdx, rax          ; guardar el resultado de x3 - x4 en rdx

    ; Llamar a sumar_c(guardado1, guardado2)
    mov rdi, r10          ; pasar el resultado de x1 - x2 en rdi
    mov rsi, rdx          ; pasar el resultado de x3 - x4 en rsi
    call sumar_c          ; llamar a sumar_c(guardado1, guardado2)

    ; epilogo
    pop rbp               
    ret                   ; retornar el resultado en rax (ya esta ahi)



; uint32_t alternate_sum_4_simplified(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4_simplified:
	sub rdi, rsi ; x1 - x2
	add rdi, rdx ; x1 - x2 + x3
	sub rdi, rcx ; x1 - x2 + x3 - x4
	mov rax, rdi ; retorno en rax
	ret


;NOTAS (borrar antes de entregar)
; despues del prologo, en [rbp] tengo el valor antiguo de rbp
; en [rbp+8] tengo la direccion de retorno (rip)
; luego, en [rbp+16] tengo el valor de x7 y en [rbp+24] tengo el valor de x8
; ojo, x7 ocupa solo 4 bytes, pero la pila se alinea a 8 bytes, por eso x8 esta en [rbp+24]

; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[rdi], x2[rsi], x3[rdx], x4[rcx], x5[r8], x6[r9], x7["r10"], x8["r11"]
alternate_sum_8:
    ; Prologo
    push rbp
    mov rbp, rsp

    ; Mover x7 y x8 a r10 y r11
    mov r10, [rbp+16] 
    mov r11, [rbp+24] 

    ; Realizar las operaciones
    sub rdi, rsi ; x1 - x2
    add rdi, rdx ; x1 - x2 + x3
    sub rdi, rcx ; x1 - x2 + x3 - x4
    add rdi, r8  ; x1 - x2 + x3 - x4 + x5
    sub rdi, r9  ; x1 - x2 + x3 - x4 + x5 - x6
    add rdi, r10 ; x1 - x2 + x3 - x4 + x5 - x6 + x7
    sub rdi, r11 ; x1 - x2 + x3 - x4 + x5 - x6 + x7 - x8

    ; Mover el resultado a rax
    mov rax, rdi

    ; Epilogo
    pop rbp
    ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[rdi], x1[rsi], f1[xmm0]
product_2_f:
	;prologo
	push rbp
	mov rbp, rsp

	;convertimos x1 y f1 a single y lo multiplicamos por f1
	cvtsi2ss xmm1, rsi ; x1
	mulss xmm1, xmm0 ; x1 * f1

	;movemos el resultado a destination (convertido a entero TRUNCADO, por eso cvtT)
	cvttss2si rax, xmm1
	mov [rdi], rax
	;epilogo
	pop rbp
	ret


;extern void product_9_f(double * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[rsi], f1[xmm0], x2[rdx], f2[xmm1], x3[rcx], f3[xmm2], x4[r8], f4[xmm3]
;	, x5[r9], f5[xmm4], x6[pila], f6[xmm5], x7[pila], f7[xmm6], x8[pila], f8[xmm7],
;	, x9[pila], f9[pila]
product_9_f:
	;prologo
	push rbp
	mov rbp, rsp
	
	;convertimos los flotantes de cada registro xmm en doubles
	cvtss2sd xmm0, xmm0 ; f1
	cvtss2sd xmm1, xmm1 ; f2
	cvtss2sd xmm2, xmm2 ; f3
	cvtss2sd xmm3, xmm3 ; f4
	cvtss2sd xmm4, xmm4 ; f5
	cvtss2sd xmm5, xmm5 ; f6
	cvtss2sd xmm6, xmm6 ; f7
	cvtss2sd xmm7, xmm7 ; f8
	cvtss2sd xmm8, [rsp+48] ; f9

	;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmmo * xmm2 , ...
	mulsd xmm0, xmm1
	mulsd xmm0, xmm2
	mulsd xmm0, xmm3
	mulsd xmm0, xmm4
	mulsd xmm0, xmm5
	mulsd xmm0, xmm6
	mulsd xmm0, xmm7
	mulsd xmm0, xmm8

	; ; convertimos los enteros en doubles y los multiplicamos por xmm0.
	cvtsi2sd xmm1, rsi ; x1
	cvtsi2sd xmm2, rdx ; x2
	cvtsi2sd xmm3, rcx ; x3
	cvtsi2sd xmm4, r8 ; x4
	cvtsi2sd xmm5, r9 ; x5
	cvtsi2sd xmm6, [rsp+16] ; x9
	cvtsi2sd xmm7, [rsp+24] ; x8
	cvtsi2sd xmm8, [rsp+32] ; x7
	cvtsi2sd xmm9, [rsp+40] ; x6

	mulsd xmm0, xmm1
	mulsd xmm0, xmm2
	mulsd xmm0, xmm3
	mulsd xmm0, xmm4
	mulsd xmm0, xmm5
	mulsd xmm0, xmm6
	mulsd xmm0, xmm7
	mulsd xmm0, xmm8
	mulsd xmm0, xmm9

	cvttss2si eax, xmm0 ; hago la recomendacion de pasar de flotante a entero
	;movemos el resultado a destination
	movsd [rdi], eax

	; epilogo
	pop rbp
	ret


