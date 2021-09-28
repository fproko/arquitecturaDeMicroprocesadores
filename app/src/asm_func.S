.syntax unified
.thumb
.text

@ Simbolos exportados
.global asm_sum
.global asm_svc
.global asm_zeros

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
    
