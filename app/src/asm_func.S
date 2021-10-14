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
.global asm_pack32to16
.global asm_max
.global asm_invertir
@ .global asm_asm_eco
@ .global asm_asm_ecoSIMD


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
@
@ Parametros de función
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

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_pack32to16 (int32_t * vectorIn, int16_t *vectorOut, uint32_t longitud)
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@   r2: logitud
@
@ Parametros de función
@   r3: aux
.thumb_func
    asm_pack32to16:
@ Realizo un loop decrementando el valor de longitud
    .loop_pack32to16:           @ etiqueta para el salto
        ldr r3, [r0],4          @ Cargo *vectorIn en r3, y luego incremento 4
        lsr r3, 16              @ r3 >> 16 y lo guardo en r3
        strh r3, [r1],2         @ Cargo valor de r3 a la dirección apuntada por r0, y luego incremendo en 2 la diección de r1
        subs r2, 1              @ Decremento el contador
        bne .loop_pack32to16
    bx lr                       @ para realizar un salto hacia afuera

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   int32_t asm_max (int32_t * vectorIn, uint32_t longitud)
@
@ Parametros recibidos:
@   r0: *vector
@   r1: longitud
@
@ Registros utilizados
@   r2: mayor 
@   r3: pos_mayor
@   r5: copia de la longitud

.thumb_func
    asm_max:
    push {r4-r5}
    mov r5, r1          @ guardo copia de longitud para utilizarlo como indice
    mov r3, r1          @ posición del ultimo elemento 
    ldr r4,[r0],+4      @ cargo vectorIn[0] en r4 y luego a r0 lo incremento 4
    subs r5,1           @ --longitud
    .loop_max:          @ etiqueta para el salto 
        ldr r2,[r0],+4  @ cargo vectorIn[1] en r2 y luego a r0 lo incremento 4
        cmp r4,r2       @ comparo mayor<vectorIn[i]
        bge .not_max    @ salto si valor actual es el máximo
        mov r4,r2       @ guardo nuevo máximo
        mov r3,r5       @ guardo valor del contador
        .not_max:
        subs r5,1       @ --longitud
        bne .loop_max   @ realiza el salto mientras el flag z!=0, esto lo determina la instrucción anterior
    sub r0,r1,r3        @ obtengo posición con la ayuda del contador que guarde y con el valor de longitud
    pop {r4-r5}
    bx lr           @ para realizar un salto hacia afuera

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_invertir (uint16_t * vector, uint32_t longitud)
@
@ Parametros recibidos:
@   r0: *vector
@   r1: longitud

.thumb_func
asm_invertir:
    push {r4}
    mov r2, 2                   
    mul r2, r1                  @ largo en bytes, equivalente a multiplicar por 2 la longitud
    add r2, r0                  @ direccion fin de vector (r0 + largo en bytes)
    sub r2, 2                   @ direccion de ultimo elemento del vector
    lsr r1, 1                   @ divido longitud por 2
    .loop_invertir:  
        ldrh r4, [r2]           @ guardo parte alta del vector     
        ldrh r3, [r0]           @ guardo parte baja del vector
        strh r3, [r2],-2        @ intercambio, y decremento r2-=2
        strh r4, [r0],+2        @ intercambio, y incremento r0+=2
        subs r1, 1              @ longitud/2 - 1 
        bne .loop_invertir      
    pop	{r4}                    
    bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_ecoSIMD (int16_t * vectorIn, int16_t * vectorOut1)
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut1