extern malloc
extern free
extern fprintf

section .data

section .text
global strLen
global strCmp
global strClone
global strDelete
global strPrint

; ** String **

; int32_t strCmp(char* a, char* b)
; registros: a[rdi], b[rsi]
; retorna 0 si a==b, 1 si a<b, -1 si a>b
strCmp:
	; prologo
	push rbp
	mov rbp, rsp

	; cargo primer char
	mov r8b, [rdi]
	mov r9b, [rsi]

    ; caso base: strings vacios
    cmp r8b, 0
    jne .check_second_string  ; a!= '', comparo con b
    cmp r9b, 0
    je .a_eq_b                ; a == '' y b == '', retorno a==b
	jmp .a_lt_b               ; si a == '' y b != '', a<b


	.check_second_string:
		; a no es vacio
		cmp r9b, 0
		je .a_gt_b ; si a != '' y b == '', a>b. 
				   ; Si b != '' y a != '', arranca el loop.


	.loop:
		cmp r8b, r9b 
		jne .comparar_resultado ; si son distintos, comparo y retorno

		cmp r8b, 0
		je .a_eq_b ; si llegue al final de ambos strings y son iguales, corto y retorno 0

		; si son iguales y ningun string termino, avanzo
		inc rdi
		inc rsi

		; cargo proximos chars
		mov r8b, [rdi]
		mov r9b, [rsi]

		jmp .loop

	.comparar_resultado:
		jg .a_gt_b	; si a>b
		jl .a_lt_b  ; si a<b

	.a_gt_b:
		mov rax, -1
		jmp .end

	.a_lt_b:
		mov rax, 1
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
		cmp al, 0
		je .end
		inc rcx
		jmp .loop
	.end:
		;epilogo
		mov rax, r8
		pop rbp
		ret

; void strDelete(char* a)
; registros: a[rdi]
strDelete:
	push rbp
	mov rbp, rsp
	cmp rdi, 0
    je .end
	.loop:
		mov r8b, [rdi]
		cmp r8b, 0
		je .end
		inc rdi
		jmp .loop
	.end:
		pop rbp
		ret

; void strPrint(char* a, FILE* pFile)
; registros: a[rdi], pFile[rsi]
section .data
	message db "NULL", 0
	message_len equ $ - message
strPrint:
	;prologo
	push rbp
	mov rbp, rsp
	; me guardo mi string en rdx
	mov rdx, rdi
	; Abrir archivo (syscall open)
    mov rax, 2              ; syscall número 2 es sys_open
	mov rdi, rsi            ; nombre del archivo
    syscall                  ; llamada al sistema (open)
	.vacio:
		mov r8b, [rdx]
		cmp r8b, 0
		je .writeNull
		jne .loop
	.writeNull:
		mov rax, 1               ; syscall número 1 es sys_write
		mov rsi, message         ; puntero al mensaje
		mov rdx, message_len     ; longitud del mensaje
		syscall                  ; llamada al sistema (write)
    .loop:
		mov r8b, [rdx]
		cmp r8b, 0
		je .end
		mov rax, 1               ; syscall número 1 es sys_write
		mov rsi, rdx             ; puntero al mensaje
		mov rdx, 1               ; longitud del mensaje
		syscall                  ; llamada al sistema (write)
		inc rdx
		jmp .loop
	.end:
		;epilogo
		pop rbp
		ret

; uint32_t strLen(char* a)
; registros: a[rdi]
strLen:
	xor rax, rax
	ret

	
	; xor rcx, rcx ; contador de longitud en 0
	
	; .loop:
	; 	mov r8b, [rdi]
	; 	cmp r8b, 0
	; 	je .end
	; 	add rcx, 1
	; 	inc rdi
	; 	jmp .loop
	; .end:
	; 	;epilogo
	; 	pop rbp
	; 	mov rax, rcx
	; 	ret 


