extern malloc
extern free
extern fprintf

section .data
message db "NULL", 0
message_len equ $ - message

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

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

	.loop:
		; si llegué al final de a, valido si llegué al final de b
		cmp r8b, 0
		je .first_string_end

		; si no llegué al final de a, pero sí de b
		cmp r9b, 0
		je .a_gt_b

		; si son distintos, comparo
		cmp r8b, r9b
		jne .compare_chars

		; avanzo al siguiente caracter
		inc rdi
		inc rsi
		mov r8b, [rdi]
		mov r9b, [rsi]
		jmp .loop

	.first_string_end:
		; si llegue al final de a, comparo con b
		cmp r9b, 0
		je .a_eq_b

		; si b no es vacio, vemos que estado es (necesitamos actualizar el flag con un nuevo cmp)
		cmp r8b, r9b
		jne .compare_chars

	.a_eq_b:
		; si llegue al final de ambos strings y son iguales
		xor rax, rax
		jmp .end

	.a_gt_b:		
		mov rax, -1
		jmp .end		

	.a_lt_b:
		mov rax, 1
		jmp .end

	.compare_chars:
		jg .a_gt_b
		jl .a_lt_b

	.end:
		; epilogo
		pop rbp
		ret

; Obs: jne, jg, jl, je son saltos condicionales en función al útimo cmp realizado

; char* strClone(char* a)
; registros a[rdi]
strClone:
	;prologo
	push rbp
	mov rbp, rsp

	; me guardo el puntero al string original
	mov rbx, rdi 

	; llamar a strLen y guardarlo en rdi
	call strLen
	mov rdi, rax
	inc rdi ; sumo 1 para el caracter nulo

	; pido espacio de memoria para el nuevo string
	call malloc
	mov r8, rax ; en r8 esta el puntero al espacio de memoria libre para llenarlo con el str

	.loop:
		mov r9b, [rbx] ; leo el primer caracter
		cmp r9b, 0     ; si es 0, corto
		je .end
		mov [r8], r9b  ; copio el caracter
		inc rbx 	   ; incrementamos y vamos al sig caracter
		inc r8 		   ; incrementamos y vamos a la sig pos vacia
		jmp .loop 		

	.end:
		;epilogo
		mov byte [r8], 0
		pop rbp
		ret
	

; void strDelete(char* a)
; registros: a[rdi]
strDelete:
	; prologo
	push rbp
	mov rbp, rsp

	; si el puntero es null
	cmp rdi, 0		
    je .end
	
	; llamar a free
	call free

	; epilogo
	.end:
		pop rbp
		ret

; void strPrint(char* a, FILE* pFile)
; registros: a[rdi], pFile[rsi]
strPrint:
	;prologo
	push rbp
	mov rbp, rsp

	;me guardo mi string en rdx
	mov rdx, rdi

	;abrir archivo (syscall open)
    mov rax, 2              ; syscall número 2 es sys_open
	mov rdi, rsi            ; nombre del archivo
    syscall                 ; llamada al sistema (open)

	.vacio:
		mov r8b, [rdx]
		cmp r8b, 0
		je .writeNull
		jne .loop

	.writeNull:
		mov rax, 1               ; syscall número 1 es sys_write
		mov rsi, message         ; puntero al mensaje (en .data)
		mov rdx, message_len     ; longitud del mensaje
		syscall                  ; llamada al sistema (write)

    .loop:
		;leo el caracter, si es 0 corto
		mov r8b, [rdx]
		cmp r8b, 0
		je .end

		;escribo el caracter en el archivo
		mov rax, 1               ; syscall número 1 es sys_write
		mov rsi, rdx             ; puntero al mensaje
		mov rdx, 1               ; longitud del mensaje
		syscall                  ; llamada al sistema (write)

		;avanzo al siguiente caracter
		inc rdx
		jmp .loop

	.end:
		;epilogo
		pop rbp
		ret


; uint32_t strLen(char* a)
; registros: a[rdi]
strLen:
	; prologo
	push rbp
	mov rbp, rsp

	xor rcx, rcx ; contador de longitud en 0
	
	.loop:
		; leo el caracter
		mov r8b, [rdi]

		; si llegue al final del string, corto
		cmp r8b, 0
		je .end

		; si no llegue al final, avanzo
		add rcx, 1
		inc rdi			; avanzo al siguiente caracter
		jmp .loop

	.end:
		;epilogo
		pop rbp
		mov rax, rcx
		ret 


