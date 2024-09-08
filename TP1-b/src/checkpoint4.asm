extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
; registros: a[rdi], b[rsi]
; retorna 0 si a==b, 1 si a>b, -1 si a<b
strCmp:
	; prologo
	push rbp
	mov rbp, rsp

	; cargo primer char
	mov r8b, [rdi]
	mov r9b, [rsi]

    ; caso ambos strings vacios
    cmp r8b, 0
    jne .check_second_string  ; si el primer string no es vacío, continuar la comparación
    cmp r9b, 0
    je .a_eq_b                ; si ambos son vacíos, retornar 0 (iguales)
    jmp .a_lt_b               ; si solo el primero es vacío, a < b

	.check_second_string:
		cmp r9b, 0
		je .a_gt_b    

	.loop:
		mov r8b, [rdi]
		mov r9b, [rsi]
		cmp r8b, r9b
		; si son iguales, avanzo un caracter
		jne .comparar_resultado

		cmp r8b, 0
		je .a_eq_b ; si llegue al final de ambos strings y son iguales, corto y retorno 0

		; si son iguales y ningun string termino, avanzo
		inc rdi
		inc rsi
		jmp .loop

	.comparar_resultado:
		jg .a_gt_b	; si a>b
		jl .a_lt_b  ; si a<b

	.a_gt_b:
		mov rax, 1
		jmp .end

	.a_lt_b:
		mov rax, -1
		jmp .end

	.a_eq_b:
		xor rax, rax ; retorno 0
		jmp .end
	.end:
		; epilogo
		pop rbp
		ret


; char* strClone(char* a)
; registros a[rdi]
strClone:
	;prologo
	push rbp
	mov rbp, rsp
	mov rsi, rdi
	xor rcx, rcx
	.calc_len:
        cmp byte [rsi + rcx], 0
        je .alloc_mem
        inc rcx
        jmp .calc_len
	.alloc_mem:
        ; Reservar memoria para el nuevo string (rcx + 1 para el byte nulo)
        mov rdi, rcx
        inc rdi
        call malloc
        mov r8, rax  ; r8 apunta al nuevo string
	mov rsi, rdi
	xor rcx, rcx
	.loop:
		mov al, [rsi + rcx]
		mov [r8 + rcx], al
		cmp1 al, 0
		je .end
		inc rcx
		jmp .loop
	.end:
		;epilogo
		mov rax, r8
		pop rbp
		ret

; void strDelete(char* a)
strDelete:
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:
	ret

; uint32_t strLen(char* a)
strLen:
	ret


