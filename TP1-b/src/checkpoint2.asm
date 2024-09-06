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
	; no me queda claro si tengo que alinear o no
	sub rdi, rsi ; x1 - x2
	add rdi, rdx ; x1 - x2 + x3
	sub rdi, rcx ; x1 - x2 + x3 - x4
	mov rax, rdi ; retorno en rax
	pop rbp
	ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4_using_c:
	;prologo
	push rbp ; alineado a 16
	mov rbp,rsp
	; llamo a restar con x1 y x2
	call restar_c
	mov rbx, rax ; me guardo el resultado en rbx
	; llamo a restar con x3 y x4, pasando el valor de x3 en rdi y x4 en rsi
	mov rdi, rdx
	mov rsi, rcx
	call restar_c
	mov rdx, rax ; me guardo el resultado en rdx
	; llamo a sumar con el resultado de las dos restas
	mov rdi, rbx
	mov rsi, rdx
	call sumar_c
	mov rax, rax 
	;epilogo
	pop rbp
	ret



; uint32_t alternate_sum_4_simplified(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4_simplified:
	sub rdi, rsi ; x1 - x2
	add rdi, rdx ; x1 - x2 + x3
	sub rdi, rcx ; x1 - x2 + x3 - x4
	mov rax, rdi ; retorno en rax
	ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[rdi], x2[rsi], x3[rdx], x4[rcx], x5[r8], x6[r9], x7[r10], x8[r11]
alternate_sum_8:
    ; Prologo
    push rbp
    mov rbp, rsp

    ; Mover x7 y x8 a registros temporales
    mov r10, [rbp+16] ; x7
    mov r11, [rbp+24] ; x8

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
	;epilogo
	push rbp
	mov rbp, rsp

	;convertimos x1 y f1 a double y lo multiplicamos por f1
	cvtsi2sd xmm1, rsi ; x1
    cvtss2sd xmm2, xmm0 ; f1
	mulsd xmm1, xmm2 ; x1 * f1

	;movemos el resultado a destination
	cvtsd2si rax, xmm1
	mov [rdi], rax

	pop rbp
	;prologo
	ret


;extern void product_9_f(double * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[?], f1[?], x2[?], f2[?], x3[?], f3[?], x4[?], f4[?]
;	, x5[?], f5[?], x6[?], f6[?], x7[?], f7[?], x8[?], f8[?],
;	, x9[?], f9[?]
product_9_f:
	;prologo
	push rbp
	mov rbp, rsp

	;convertimos los flotantes de cada registro xmm en doubles
	; COMPLETAR

	;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmmo * xmm2 , ...
	; COMPLETAR

	; convertimos los enteros en doubles y los multiplicamos por xmm0.
	; COMPLETAR

	; epilogo
	pop rbp
	ret


