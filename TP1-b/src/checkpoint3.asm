

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar:
NODO_LENGTH	EQU	32
LONGITUD_OFFSET	EQU	24

PACKED_NODO_LENGTH	EQU	21
PACKED_LONGITUD_OFFSET	EQU	17
;########### SECCION DE DATOS
section .data
	mask dq 0x0000_0000_FFFF_FFFF

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

;########### DEFINICION DE FUNCIONES
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
;registros: lista[rdi]
cantidad_total_de_elementos:
	; prologo
	push rbp
	mov rbp, rsp

	; inicializo mi respuesta en 0
	xor rax,rax

	; en rdi tengo la direccion de la lista. quiero entonces ya tener el primer nodo
	mov rdi, [rdi]

	.loop_nodos:
		; si el puntero es null, corto
		cmp rdi, 0
		je .end_loop
		
		; leo la longitud del nodo
		mov r8, [rdi + LONGITUD_OFFSET]

		and r8, [mask]	; me quedo con los primeros 32 bits
		add rax, r8		; sumo la longitud del nodo a mi respuesta

		mov rdi, [rdi]  ; avanzo
		jmp .loop_nodos

	.end_loop:
		pop rbp
		ret

;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros: lista[rdi]
cantidad_total_de_elementos_packed:
	; prologo
	push rbp
	mov rbp, rsp

	; inicializo mi respuesta en 0
	xor rax,rax

	; en rdi tengo la direccion de la lista. quiero entonces ya tener el primer nodo
	mov rdi, [rdi]

	.loop_nodos:
		; si el puntero es null, corto
		cmp rdi, 0
		je .end_loop
		
		; leo la longitud del nodo
		mov r8, [rdi + PACKED_LONGITUD_OFFSET]

		and r8, [mask]	; me quedo con los primeros 32 bits
		add rax, r8		; sumo la longitud del nodo a mi respuesta

		mov rdi, [rdi]  ; avanzo
		jmp .loop_nodos

	.end_loop:
		pop rbp
		ret


