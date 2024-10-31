; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TALLER System Programming - Arquitectura y Organizacion de Computadoras - FCEN
; ==============================================================================

%include "print.mac"

global start


; COMPLETAR - Agreguen declaraciones extern según vayan necesitando
extern GDT_DESC, IDT_DESC, idt_init, screen_draw_layout, screen_draw_box
extern pic_reset, pic_enable, pic_change_freq
extern mmu_init_kernel_dir, mmu_init_task_dir, copy_page, page_fault_handler
extern tss_init, tasks_screen_draw, sched_init, tasks_init

; COMPLETAR - Definan correctamente estas constantes cuando las necesiten
%define CS_RING_0_SEL 8
%define DS_RING_0_SEL 24
%define C_FG_LIGHT_CYAN (0x0B)
%define GDT_TASK_INITIAL_SEL (11 << 3)
%define GDT_TASK_IDLE_SEL (12 << 3)





BITS 16
;; Saltear seccion de datos
jmp start

;;
;; Seccion de datos.
;; -------------------------------------------------------------------------- ;;
start_rm_msg db     'Iniciando kernel en Modo Real'
start_rm_len equ    $ - start_rm_msg

start_pm_msg db     'Iniciando kernel en Modo Protegido'
start_pm_len equ    $ - start_pm_msg

;;
;; Seccion de código.
;; -------------------------------------------------------------------------- ;;

;; Punto de entrada del kernel.
BITS 16
start:
    ; COMPLETAR - Deshabilitar interrupciones
    cli

    ; Cambiar modo de video a 80 X 50
    mov ax, 0003h
    int 10h ; set mode 03h
    xor bx, bx
    mov ax, 1112h
    int 10h ; load 8x8 font

    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO REAL
    print_text_rm start_rm_msg, start_rm_len, C_FG_LIGHT_CYAN, 0x00, 0x00

    ; COMPLETAR - Habilitar A20
    call A20_enable

    ; COMPLETAR - Cargar la GDT
    lgdt [GDT_DESC]
    ; COMPLETAR - Setear el bit PE del registro CR0
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    ; COMPLETAR - Saltar a modo protegido (far jump)
    jmp CS_RING_0_SEL:modo_protegido


BITS 32
modo_protegido:
    ; COMPLETAR - A partir de aca, todo el codigo se va a ejectutar en modo protegido
    ; Establecer selectores de segmentos DS, ES, GS, FS y SS en el segmento de datos de nivel 0
    ; Pueden usar la constante DS_RING_0_SEL definida en este archivo
    mov ax, DS_RING_0_SEL
    mov ds, ax
    mov es, ax
    mov gs, ax
    mov fs, ax
    mov ss, ax

    ; setear la pila del kernel en 0x25000
    mov esp, 0x25000
    mov ebp, esp

    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO PROTEGIDO
    print_text_pm start_pm_msg, start_pm_len, C_FG_LIGHT_CYAN, 0x00, 0x00

    ; COMPLETAR - Inicializar pantalla
    call screen_draw_layout
    
    ; inicializar y cargar IDTs
    call idt_init
    lidt [IDT_DESC]

    ; reiniciar y habilitar el PIC
    call pic_reset
    call pic_enable

    ; cambiar frecuencia del clock
    call pic_change_freq

    ; INICIO KPD
    call mmu_init_kernel_dir
    and eax, 0xFFFFF000 ; los primeros 20 bits nada mas, resto en 0
    mov cr3, eax

    ; habilito paginacion
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax

    push 0x0
    push 0x10000
    call copy_page


    ; init tss
    call tss_init

    ; init scheduler
    call sched_init

    ; init tareas
    call tasks_init

    ; init idt
    ; reiniciar y habilitar el controlador de interrupciones


    ; cargar tarea inicial 
    mov ax, GDT_TASK_INITIAL_SEL
    ltr ax

    ; habilitar interrupciones

    ; init directorio de paginas de la tarea de prueba
    ; cargar directorio de paginas de tarea
    ; restaurar directorio de paginas del kernel

    ; saltar a idle
    jmp GDT_TASK_IDLE_SEL:0

    ; Ciclar infinitamente 
    mov eax, 0xFFFF
    mov ebx, 0xFFFF
    mov ecx, 0xFFFF
    mov edx, 0xFFFF
    jmp $

;; -------------------------------------------------------------------------- ;;

%include "a20.asm"
