# System Programming: Tareas.

Vamos a continuar trabajando con el kernel que estuvimos programando en
los talleres anteriores. La idea es incorporar la posibilidad de
ejecutar algunas tareas específicas. Para esto vamos a precisar:

-   Definir las estructuras de las tareas disponibles para ser
    ejecutadas

-   Tener un scheduler que determine la tarea a la que le toca
    ejecutase en un período de tiempo, y el mecanismo para el
    intercambio de tareas de la CPU

-   Iniciar el kernel con una *tarea inicial* y tener una *tarea idle*
    para cuando no haya tareas en ejecución

Recordamos el mapeo de memoria con el que venimos trabajando. Las tareas
que vamos a crear en este taller van a ser parte de esta organización de
la memoria:

![](img/mapa_fisico.png)

![](img/mapeo_detallado.png)

## Archivos provistos

A continuación les pasamos la lista de archivos que forman parte del
taller de hoy junto con su descripción:

-   **Makefile** - encargado de compilar y generar la imagen del
    floppy disk.

-   **idle.asm** - código de la tarea Idle.

-   **shared.h** -- estructura de la página de memoria compartida

-   **tareas/syscall.h** - interfaz para realizar llamadas al sistema
    desde las tareas

-   **tareas/task_lib.h** - Biblioteca con funciones útiles para las
    tareas

-   **tareas/task_prelude.asm**- Código de inicialización para las
    tareas

-   **tareas/taskPong.c** -- código de la tarea que usaremos
    (**tareas/taskGameOfLife.c, tareas/taskSnake.c,
    tareas/taskTipear.c **- código de otras tareas de ejemplo)

-   **tareas/taskPongScoreboard.c** -- código de la tarea que deberán
    completar

-   **tss.h, tss.c** - definición de estructuras y funciones para el
    manejo de las TSSs

-   **sched.h, sched.c** - scheduler del kernel

-   **tasks.h, tasks.c** - Definición de estructuras y funciones para
    la administración de tareas

-   **isr.asm** - Handlers de excepciones y interrupciones (en este
    caso se proveen las rutinas de atención de interrupciones)

-   **task\_defines.h** - Definiciones generales referente a tareas

## Ejercicios

### Primera parte: Inicialización de tareas

**1.** Si queremos definir un sistema que utilice sólo dos tareas, ¿Qué
nuevas estructuras, cantidad de nuevas entradas en las estructuras ya
definidas, y registros tenemos que configurar?¿Qué formato tienen?
¿Dónde se encuentran almacenadas?

- Tenemos que agregar dos entradas que tengan un descriptor TSS en la GDT. Los TSS (task segment selectors) son los que indican el estado de la tarea (la *foto* del procesador en ese momento), existe uno de estos por cada tarea.
- Para acceder al TSS se usa el TR (Task Register). En este registro se guarda el selector en la GDT donde esta el TSS Descriptor.
    - Ademas, tiene una parte "invisible", que cachea la base address y el segment limit de ese selector, para evitar tener que ir a buscarlo a la gdt de vuelta.
        - Este procedimiento lo hace el procesador de manera automatica.


**2.** ¿A qué llamamos cambio de contexto? ¿Cuándo se produce? ¿Qué efecto
tiene sobre los registros del procesador? Expliquen en sus palabras que
almacena el registro **TR** y cómo obtiene la información necesaria para
ejecutar una tarea después de un cambio de contexto.

- Llamamos cambio de contexto a cambiar de una tarea a otra. Este cambio de tareas sucede cuando se hace el jmp far hacia la tarea.
- El efecto que tiene sobre los registros del procesador es que se guardan los valores de los registros en la TSS de la tarea que se esta ejecutando (la *foto* que guarda), y se cargan los valores de los registros de la TSS de la tarea a la que se va a saltar (la *foto* que se carga). El estado nuevo que se carga es el de la nueva tarea, que se indica mediante el jmp far.

- El registro TR guarda el selector de segmento de la GDT que contiene el TSS descriptor de la tarea actual. Para ejecutar la tarea luego del cambio de contexto, cuando cargue la *foto* de la tarea, el procesador ya va a tener la informacion necesaria para ejecutar la tarea, es decir, va a tener seteada la pila de su tarea, va a tener el instruction pointer donde lo dejo la ultima vez, al igual que los registros de segmento y de proposito general.

**3.** Al momento de realizar un cambio de contexto el procesador va
almacenar el estado actual de acuerdo al selector indicado en el
registro **TR** y ha de restaurar aquel almacenado en la TSS cuyo
selector se asigna en el *jmp* far. ¿Qué consideraciones deberíamos
tener para poder realizar el primer cambio de contexto? ¿Y cuáles cuando
no tenemos tareas que ejecutar o se encuentran todas suspendidas?

- Para realizar el primer cambio de contexto, necesitamos tener la "tarea inicial", una tarea que solo sirve para que el procesador este ejecutando alguna tarea. Tenemos que cargar el TR con el selector de la GDT que contiene el TSS descriptor de la tarea inicial.
Luego, tenemos que pasar a la tarea idle, que es la tarea que se ejecuta cuando no hay tareas para ejecutar. Esta tarea es importante ya que siempre queremos que el procesador este ejecutando alguna tarea.  Pasamos a esta tarea con el jmp far a la tarea idle, a la cual le tenemos que definir su selector de segmento en la GDT.

**4.** ¿Qué hace el scheduler de un Sistema Operativo? ¿A qué nos
referimos con que usa una política?

- El scheduler de un SO es el software que decide cual es la siguiente tarea a ejecutar.
- La politica que usa es solamente la manera que tiene ese software de determinar cual es la proxima tarea que se ejecuta. En nuestro caso era una politica "round robin", es decir que va una por una, pero la politica podria ser distinta, manteniendo una jerarquia de prioridades entre tareas.

**5.** En un sistema de una única CPU, ¿cómo se hace para que los
programas parezcan ejecutarse en simultáneo?
- Lo que se hace para que parezca que los programas se ejecuten en simultaneo es justamente cambiar de tareas. El cambio de tarea es tan rapido que no es perceptible para el usuario, y parece que las tareas se ejecutan en simultaneo, cuando en realidad se ejecutan una por una.

**6.** En **tss.c** se encuentran definidas las TSSs de la Tarea
**Inicial** e **Idle**. Ahora, vamos a agregar el *TSS Descriptor*
correspondiente a estas tareas en la **GDT**.
    
a) Observen qué hace el método: ***tss_gdt_entry_for_task***

- dada una direccion de memoria de una tss, devuelve un descriptor de la gdt que apunta a esa tss.

b) Escriban el código del método ***tss_init*** de **tss.c** que
agrega dos nuevas entradas a la **GDT** correspondientes al
descriptor de TSS de la tarea Inicial e Idle.

c) En **kernel.asm**, luego de habilitar paginación, agreguen una
llamada a **tss_init** para que efectivamente estas entradas se
agreguen a la **GDT**.

d) Correr el *qemu* y usar **info gdt** para verificar que los
***descriptores de tss*** de la tarea Inicial e Idle esten
efectivamente cargadas en la GDT

**7.** Como vimos, la primer tarea que va a ejecutar el procesador
cuando arranque va a ser la **tarea Inicial**. Se encuentra definida en
**tss.c** y tiene todos sus campos en 0. Antes de que comience a ciclar
infinitamente, completen lo necesario en **kernel.asm** para que cargue
la tarea inicial. Recuerden que la primera vez tenemos que cargar el registro
**TR** (Task Register) con la instrucción **LTR**.
Previamente llamar a la función tasks_screen_draw provista para preparar
la pantalla para nuestras tareas.

Si obtienen un error, asegurense de haber proporcionado un selector de
segmento para la tarea inicial. Un selector de segmento no es sólo el
indice en la GDT sino que tiene algunos bits con privilegios y el *table
indicator*.

**8.** Una vez que el procesador comenzó su ejecución en la **tarea Inicial**, 
le vamos a pedir que salte a la **tarea Idle** con un
***JMP***. Para eso, completar en **kernel.asm** el código necesario
para saltar intercambiando **TSS**, entre la tarea inicial y la tarea
Idle.

**9.** Utilizando **info tss**, verifiquen el valor del **TR**.
También, verifiquen los valores de los registros **CR3** con **creg** y de los registros de segmento **CS,** **DS**, **SS** con
***sreg***. ¿Por qué hace falta tener definida la pila de nivel 0 en la
tss?

- Hace falta tener definida la pila de nivel 0 en la tss para que el procesador pueda guardar el contexto cuando se produce un cambio de privilegios. Si tenemos una tarea de nivel 3 y se produce la interrupcion de reloj. Luego, cambia el nivel de ejecucion. Por eso, usa el stack de nivel 0 que esta en la tss para guardar la informacion de retorno a la tarea.

**10.** En **tss.c**, completar la función ***tss_create_user_task***
para que inicialice una TSS con los datos correspondientes a una tarea
cualquiera. La función recibe por parámetro la dirección del código de
una tarea y será utilizada más adelante para crear tareas.

Las direcciones físicas del código de las tareas se encuentran en
**defines.h** bajo los nombres ***TASK_A_CODE_START*** y
***TASK_B_CODE_START***.

El esquema de paginación a utilizar es el que hicimos durante la clase
anterior. Tener en cuenta que cada tarea utilizará una pila distinta de
nivel 0.

### Segunda parte: Poniendo todo en marcha

**11.** Estando definidas **sched_task_offset** y **sched_task_selector**:
```
  sched_task_offset: dd 0xFFFFFFFF
  sched_task_selector: dw 0xFFFF
```

Y siendo la siguiente una implementación de una interrupción del reloj:

```
global _isr32
  
_isr32:
  pushad
  call pic_finish1
  
  call sched_next_task
  
  str cx
  cmp ax, cx
  je .fin
  
  mov word [sched_task_selector], ax
  jmp far [sched_task_offset]
  
  .fin:
  popad
  iret
```
a)  Expliquen con sus palabras que se estaría ejecutando en cada tic
    del reloj línea por línea

- pushad: se guarda el estado de los registros de proposito general en la pila de nivel 0 de la tarea actual. Se usa la de nivel 0 porque estamos en una interrupcion de reloj.

- call pic_finish1: se avisa al pic que se termino de atender la interrupcion.

- call sched_next_task: se llama al scheduler para que devuelva el segment selector de la proxima tarea a ejecutar.

- str cx: se guarda el TR en cx, es decir, el segment selector de la tarea actual.

- cmp ax, cx: se compara el segment selector de la tarea actual con el segment selector de la proxima tarea a ejecutar.

- je .fin: si son los mismos, no se cambia de tarea y se salta a .fin.

    - en .fin se restauran los registros de proposito general (que estaban en la pila de nivel 0) y se retorna de la interrupcion, volviendo a ejecutar la tarea.

- mov word [sched_task_selector], ax: se guarda el segment selector de la proxima tarea a ejecutar en sched_task_selector.
- jmp far [sched_task_offset]: se salta a la proxima tarea a ejecutar, usando el segment selector de la proxima tarea.\
    - Aca se produce el context switch, que guarda el estado de la tarea actual en la TSS, cambia el TR por el segment selector de la proxima tarea, y carga el estado de la proxima tarea de su TSS correspondiente.
    - Cuando se vuelva a ejecutar esta tarea, el EIP habra quedado apuntando a .fin, entonces cuando se vuelva a ejecutar, se restauran los registros de proposito general, que nos dicen donde estaba la tarea antes de que se produzca la interrupcion de reloj. Luego, con el iret se vuelve a ejecutar la tarea.

b)  En la línea que dice ***jmp far \[sched_task_offset\]*** ¿De que
    tamaño es el dato que estaría leyendo desde la memoria? ¿Qué
    indica cada uno de estos valores? ¿Tiene algún efecto el offset
    elegido?

- El selector es de 2 bytes (16 bits) y el offset es de 4 bytes (32 bits). En este tipo de jmp far, el offset es ignorado, ya que no lo necesita para determinar a donde saltar, se lo dice la TSS. De todas maneras, el offset tiene que estar ahi para que la instruccion sea valida.

c)  ¿A dónde regresa la ejecución (***eip***) de una tarea cuando
    vuelve a ser puesta en ejecución?

- Si la tarea ya se ejecuto alguna vez y vuelve a ejecutarse de vuelta, va a volver a .fin, ya que ahi es donde quedo apuntando el eip. Ahi va a restaurar sus registros de proposito general para poder volver al codigo propio de la tarea con el iret.


**12.** Para este Taller la cátedra ha creado un scheduler que devuelve
la próxima tarea a ejecutar.

a)  En los archivos **sched.c** y **sched.h** se encuentran definidos
    los métodos necesarios para el Scheduler. Expliquen cómo funciona
    el mismo, es decir, cómo decide cuál es la próxima tarea a
    ejecutar. Pueden encontrarlo en la función ***sched_next_task***.

- El scheduler itera sobre las tasks que hay en `sched_tasks`, empezando sobre la actual, y da toda la vuelta hasta encontrar alguna (que no sea la actual), que este disponible para ejecucion. Si no encuentra ninguna, devuelve la `idle`. Si encuentra alguna, setea la actual a esa y devuelve el segment selector de esa tarea (lo tiene en `sched_tasks`).

b)  Modifiquen **kernel.asm** para llamar a la función
    ***sched_init*** luego de iniciar la TSS

c)  Compilen, ejecuten ***qemu*** y vean que todo sigue funcionando
    correctamente.

### Tercera parte: Tareas? Qué es eso?

**14.** Como parte de la inicialización del kernel, en kernel.asm se
pide agregar una llamada a la función **tasks\_init** de
**task.c** que a su vez llama a **create_task**. Observe las
siguientes líneas:
```C
int8_t task_id = sched_add_task(gdt_id << 3);

tss_tasks[task_id] = tss_create_user_task(task_code_start[tipo]);

gdt[gdt_id] = tss_gdt_entry_for_task(&tss_tasks[task_id]);
```
a)  ¿Qué está haciendo la función ***tss_gdt_entry_for_task***?

- Dado el tss, genera su entrada en la gdt. El task_id es el selector de segmento que se va a guardar en el TR, entonces, tenemos que guardar en la GDT la entrada que le corresponde a ese selector de segmento.

b)  ¿Por qué motivo se realiza el desplazamiento a izquierda de
    **gdt_id** al pasarlo como parámetro de ***sched_add_task***?

- Porque gdt_id es el indice en la gdt, y sched_add_task recibe el selector de segmento, que tiene 3 bits al principio que le indican el TI (table indicator) y el RPL, ambos 0.

**15.** Ejecuten las tareas en *qemu* y observen el código de estas
superficialmente.

a) ¿Qué mecanismos usan para comunicarse con el kernel?

- Observamos que la manera de interactuar es con syscall. Ejemplo en la de GameOfLife usan int 88.

b) ¿Por qué creen que no hay uso de variables globales? ¿Qué pasaría si
    una tarea intentase escribir en su `.data` con nuestro sistema?

- 

c) Cambien el divisor del PIT para \"acelerar\" la ejecución de las tareas:
```
    ; El PIT (Programmable Interrupt Timer) corre a 1193182Hz.

    ; Cada iteracion del clock decrementa un contador interno, cuando
    éste llega

    ; a cero se emite la interrupción. El valor inicial es 0x0 que
    indica 65536,

    ; es decir 18.206 Hz

    mov ax, DIVISOR

    out 0x40, al

    rol ax, 8

    out 0x40, al
```

**16.** Observen **tareas/task_prelude.asm**. El código de este archivo
se ubica al principio de las tareas.

a. ¿Por qué la tarea termina en un loop infinito?
- Esto es para que ninguna tarea pueda terminar, que siempre siga viva. Nuestro kernel no soporta la terminacion de tareas.

b. \[Opcional\] ¿Qué podríamos hacer para que esto no sea necesario?
- Se podrian implementar algunas syscalls para que el kernel maneje la situacion. Se podria, por ejemplo, implementar una syscall que directamente pase a la siguiente tarea y marque la actual como no disponible, haciendo que esta tarea no se ejecute mas

### Cuarta parte: Hacer nuestra propia tarea

Ahora programaremos nuestra tarea. La idea es disponer de una tarea que
imprima el *score* (puntaje) de todos los *Pongs* que se están
ejecutando. Para ello utilizaremos la memoria mapeada *on demand* del
taller anterior.

#### Análisis:

**18.** Analicen el *Makefile* provisto. ¿Por qué se definen 2 "tipos"
de tareas? ¿Como harían para ejecutar una tarea distinta? Cambien la
tarea S*nake* por una tarea *PongScoreboard*.

- Se definen dos tipos de tareas porque hay varias que son "una instancia" de Snake / Pong. Es decir, hay 3 tareas que estan corriendo el juego Pong y una corriendo el juego snake. Entonces, para poder diferenciarlas, se les asigna un tipo distinto.
- Para ejecutar una tarea distinta, podriamos intercambiarles los tipos. De todos modos, el hecho de que haya 3 instancias de la tarea A y una instancia de la tarea B se define en `tasks_init()`. Si queremos reemplazar todas las tareas snake por tareas PongScoreboard, con cambiar el tipo en el Makefile alcanza.

**19.** Mirando la tarea *Pong*, ¿En que posición de memoria escribe
esta tarea el puntaje que queremos imprimir? ¿Cómo funciona el mecanismo
propuesto para compartir datos entre tareas?

- Escribe en la posicion que asignamos como memoria compartida entre tareas (es la que, inicialmente, ninguna tarea tiene mapeada, pero si la quieren acceder y eso levanta un page fault, la mapea para esa tarea). Esta posicion se llama (en `taskPong.c`) `SHARED_SCORE_BASE_VADDR`.
- El mecanismo para compartir datos entre tareas es que, todas las tareas van a usar esa misma pagina, pero cada una va a usar un rango propio para cada tarea, que se calcula con el `task_id`. De ese modo, ninguna tarea va a pisar el score de la otra. Asi, todas las tareas pueden acceder a la misma pagina de memoria compartida, pero cada una tiene su propio espacio en esa pagina.

#### Programando:

**20.** Completen el código de la tarea *PongScoreboard* para que
imprima en la pantalla el puntaje de todas las instancias de *Pong* usando los datos que nos dejan en la página compartida.

**21.** \[Opcional\] Resuman con su equipo todas las estructuras vistas
desde el Taller 1 al Taller 4. Escriban el funcionamiento general de
segmentos, interrupciones, paginación y tareas en los procesadores
Intel. ¿Cómo interactúan las estructuras? ¿Qué configuraciones son
fundamentales a realizar? ¿Cómo son los niveles de privilegio y acceso a
las estructuras?

**22.** \[Opcional\] ¿Qué pasa cuando una tarea dispara una
excepción? ¿Cómo podría mejorarse la respuesta del sistema ante estos
eventos?
