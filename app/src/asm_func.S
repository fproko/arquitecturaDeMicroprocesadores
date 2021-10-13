.syntax unified
.thumb
.text

@ Simbolos exportados
.global asm_sum
.global asm_svc
.global asm_zeros
.global asm_productoEscalar32
.global asm_productoEscalar16
.global asm_productoEscalar12
.global asm_productoEscalar12_sat
.global asm_filtroVentana10

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   uint32_t asmSum (uint32_t firstOperand, uint32_t secondOperand)
@
@ Parametros recibidos:
@   r0: firstOperand
@   r1: secondOperand
@
@ Valor de retorno:
@   r0: resultado de la suma de firstOperand y secondOperand
@
.thumb_func
    asm_sum:
        add r0, r1  @ r0 = r0 + r1
        bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                    @ es la direccion, en el codigo del programa, de la
                    @ instruccion "bl asm_sum" usada para saltar a
                    @ esta funcion, entonces "lr" contiene ese "pc" + 4).
                    @ el valor de retorno debe quedar en el registro r0.
                    @ En este caso, r0 es el resultado de r0 + r1.

        @ Otras alternativas para el retorno
        @ mov pc,lr
        @ bx lr
        @ push {lr} ... pop {pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_svc (void)
@
.thumb_func
    asm_svc:
        svc 0 @Se invoca a la interrupcion SVC (Supervisor Call), omo parámetro admite solamente una constante
        bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_zeros (uint32_t * vector, uint32_t longitud)
@
@ Parametros recibidos:
@   r0: *vector
@   r1: longitud

.thumb_func
    asm_zeros:
        @Registros utilizados
        @ r2: valor cero
        mov r2,0        @ constante cero

@ Realizo un loop decrementando el valor de longitud
    .loop_zeros:        @ etiqueta para el salto 
        str r2,[r0],+4  @ *vector++ = r2;  
                        @ guardo constante 0 en la posición de memoria apuntada por r0 y luego a r0 lo incremento 4 porque sizeof(unint32_t)==4
        subs r1,1       @ --longitud
        bne .loop_zeros @ Realiza el salto mientras el flag z!=0, esto lo determina la instrucción anterior

        bx lr           @ para realizar un salto hacia afuera

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_productoEscalar32 (uint32_t * vectorIn, uint32_t * vectorOut, 
@                               uint32_t longitud, uint32_t escalar);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@   r2: logitud
@   r3: escalar

.thumb_func
    asm_productoEscalar32:
    push {r4} @preserva r4

@ Realizo un loop decrementando el valor de longitud
    .loop_pe32:        @ etiqueta para el salto  
        ldr r4,[r0],4  @ r4 = *r0 ; r0+=4 o r4 = *vectorIn++
        mul r4,r3      @ r4 = r4 * r3 | r4 = *vectorIn * escalar
        str r4,[r1],4  @ *vectorOut++ = r4
        subs r2,1      @ --longitud
        bne .loop_pe32

    pop {r4} @restablece r4
    bx lr           @ para realizar un salto hacia afuera

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_productoEscalar16 (uint16_t * vectorIn, uint16_t * vectorOut,
@								uint32_t longitud, uint16_t escalar);
@
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@   r2: logitud
@   r3: escalar

.thumb_func
    asm_productoEscalar16:
    push {r4} @preserva r4

@ Realizo un loop decrementando el valor de longitud
    .loop_pe16:         @ etiqueta para el salto
        ldrh r4,[r0],2  @ r4 = *r0 ; r0+=2 o r4 = *vectorIn++
        mul r4,r3       @ r4 = r4 * r3 | r4 = *vectorIn * escalar
        strh r4,[r1],2  @ *vectorOut++ = r4
        subs r2,1       @ --longitud
        bne .loop_pe16

    pop {r4}            @restablece r4
    bx lr               @ para realizar un salto hacia afuera

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_productoEscalar12 (uint16_t * vectorIn, uint16_t * vectorOut,
@								uint32_t longitud, uint16_t escalar);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@   r2: logitud
@   r3: escalar

.thumb_func
    asm_productoEscalar12:
    push {r4-r5} @preserva r4-r5

@ Realizo un loop decrementando el valor de longitud
    .loop_pe12:         @ etiqueta para el salto
        ldrh r4,[r0],2  @ r4 = *r0 ; r0+=2 o r4 = *vectorIn++
        mul r4,r3       @ r4 = r4 * r3 | r4 = *vectorIn * escalar
        lsrs r5,r4,12   @ corre 12 lugares a la derecha r4, lo guarda en r5 y actualiza flag si es cero
        beq .notsaturate
        mov r4, 0xFFF   @ si satura guarda el valor máximo de 12 bits

        .notsaturate:
        strh r4,[r1],2  @ *vectorOut++ = r4
        subs r2,1       @ --longitud
        bne .loop_pe12
    pop {r4-r5}            @restablece r4-r5
    bx lr               @ para realizar un salto hacia afuera

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_productoEscalar12_sat (uint16_t * vectorIn, uint16_t * vectorOut,
@								uint32_t longitud, uint16_t escalar);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@   r2: logitud
@   r3: escalar

.thumb_func
    asm_productoEscalar12_sat:
    push {r4} @preserva r4

@ Realizo un loop decrementando el valor de longitud
    .loop_pe12_sat:         @ etiqueta para el salto
        ldrh r4,[r0],2  @ r4 = *r0 ; r0+=2 o r4 = *vectorIn++
        mul r4,r3       @ r4 = r4 * r3 | r4 = *vectorIn * escalar
        usat r4,12,r4   @ Satura sin signo a la posicion 12
        strh r4,[r1],2  @ *vectorOut++ = r4
        subs r2,1       @ --longitud
        bne .loop_pe12_sat
    pop {r4}            @restablece r4
    bx lr               @ para realizar un salto hacia afuera

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_filtroVentana10(uint16_t * vectorIn, uint16_t * vectorOut, 
@                           uint32_t longitudVectorIn)
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@   r2: logitud
@   r3: acumulador
@   r4: variable i 
@   r5: variable j
@   r6: ventana
@   r7: max
@   r8: aux
@	r9: para devolver r0 a posicíon incial

.thumb_func
    asm_filtroVentana10:
    push {r4-r9}                @preserva r4-r9
    mov	r3, 0	                @ acumulador = 0
    mov	r4, 0	                @ i = 0
    mov	r5, 0                   @ j = 0
    mov r6, 10                  @ ventana de 10
    mov r7, 0                   @ max = 0
    mov r9, 2					@ para devolver r0 a posicíon incial
    .loop_externo:              @ loop for de variable i
        add r7,r4,r6            @ max = i + ventana
        cmp r7,r2               @ comparo con longitud
        //movhi r7,r2         	@ si i + ventana > longitud, entonces max=longitud
                                @ else max = i + ventana
        .loop_interno:
            ldrh r8, [r0],2     @ Cargo el valor del vector de entrada en aux, y luego incremento 2
            add r3, r8          @ Suma acumulador
            add r5, 1           @ j ++
            cmp r5, r6          @ comparo con máximo j
            blo .loop_interno
        sub r7,r4
        mul r7,r9               @ r7 = cantidad de desplazmientos, r9 =tamaño de desplazamiento
        sub r0, r7              @ devuelvo a la primera posición *vectorIn
        udiv r3, r3, r6         @ Divido acumulador por ventana r3=r3/r6
        strh r3, [r1], 2        @ Alamacena acumulador en vectorOut e incremento 2 vectorOut *r1=r3 ; r1+=2
        mov	r3, 0	            @ acumulador = 0
        add r4, 1               @ i ++
        cmp r4, r2              @ comparo con longitud
        blo .loop_externo       @ salta si es menor
    pop {r4-r9}                 @ restablece r4-r8
    bx lr