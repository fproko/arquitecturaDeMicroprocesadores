#include "board.h"
#include "c_func.h"
#include "asm_func.h"
#include "cmsis.h"

#include <stdlib.h>
#include <stdnoreturn.h>

#define ENABLE_DWT DWT->CTRL |= 1 << DWT_CTRL_CYCCNTENA_Pos
#define RESET_CYCLES DWT->CYCCNT = 0
#define GET_CYCLES DWT->CYCCNT

// Variable que se incrementa cada vez que se llama al handler de interrupcion
// del SYSTICK.
static volatile uint32_t s_ticks = 0;
volatile uint32_t ciclos = 0;

// Inicia soporte de la placa y periodo de la interrupcion del SYSTICK
// cada 1 milisegundo.
static void Inicio (void)
{
    Board_Init ();
    SystemCoreClockUpdate ();
    SysTick_Config (SystemCoreClock / 1000);
}


// Segun la configuracion realizada en Inicio(), este handler de interrupcion
// se ejecutara cada 1 milisegundo.
void SysTick_Handler (void)
{
    ++ s_ticks;
}

void eco(void)
{
    printf("\n\rEjercicio 10:\n\r");
	static int16_t vectorIn1[4096] , vectorIn2[4096], vectorIn3[4096];

	for( uint16_t i = 0 ; i < 4096 ; i++)
	{
		vectorIn1[i] = i ;
		vectorIn2[i] = i ;
		vectorIn3[i] = i ;
	}

	// RESET_CYCLES;
	// asm_eco(vectorIn1);
	// printf("Eco ASM : %d ciclos\n\r", GET_CYCLES);

	// RESET_CYCLES;
	// asm_ecoSIMD(vectorIn2);
    // printf("Eco ASM SIMD : %d ciclos\n\r", GET_CYCLES);

	RESET_CYCLES;
	c_eco(vectorIn3);
	printf("Eco C : %d ciclos\n\r", GET_CYCLES);
}

static void invertir(void)
{
    printf("\n\rEjercicio 9:\n\r");
    uint16_t vectorIn1[7] = {55,2,3,100,5,200,7};
    uint16_t vectorIn2[7] = {55,2,3,100,5,200,7};
    
    RESET_CYCLES;
    asm_invertir(vectorIn1,7);
    printf("Invertir ASM : %d ciclos\n\r", GET_CYCLES);
    
    RESET_CYCLES;
    c_invertir(vectorIn2,7);
    printf("Invertir C  : %d ciclos\n\r", GET_CYCLES);
}

static void max(void)
{
    printf("\n\rEjercicio 7:\n\r");
    int32_t c_pos_max=0;
    int32_t asm_pos_max=0;
    uint32_t vectorIn1[8] = {-55,2,-3,100,-5,200,-7,8};
    
    RESET_CYCLES;
    asm_pos_max=asm_max(vectorIn1,8);
    printf("max ASM : %d ciclos\n\r", GET_CYCLES);

    RESET_CYCLES;
    c_pos_max=c_max(vectorIn1,8);
    printf("max C : %d ciclos\n\r", GET_CYCLES);
}

static void pack32to16(void)
{
    printf("\n\rEjercicio 6:\n\r");
    uint32_t vectorIn1[8] = {-999999999,2,-3,4,-5,6,-7,8};
    uint16_t vectorOut1[8] = {0,0,0,0,0,0,0,0};
    uint16_t vectorOut2[8] = {0,0,0,0,0,0,0,0};

    RESET_CYCLES;
    asm_pack32to16(vectorIn1,vectorOut1,8);
    printf("pack32to16 ASM : %d ciclos\n\r", GET_CYCLES);

    RESET_CYCLES;
    c_pack32to16(vectorIn1,vectorOut2,8);
    printf("pack32to16 C : %d ciclos\n\r", GET_CYCLES);
}

static void filtroVentana10(void)
{
    printf("\n\rEjercicio 5:\n\r");
    uint16_t vectorIn1[16] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};
    uint16_t vectorOut1[16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    uint16_t vectorOut2[16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

    RESET_CYCLES;
    asm_filtroVentana10(vectorIn1, vectorOut1, 16);
    printf("filtroVentana10 ASM : %d ciclos\n\r", GET_CYCLES);
    
    RESET_CYCLES;
    c_filtroVentana10(vectorIn1, vectorOut2, 16);
    printf("filtroVentana10 C : %d ciclos\n\r", GET_CYCLES);
}

static void productoEscalar12(void)
{
    printf("\n\rEjercicio 4:\n\r");
    uint16_t vectorIn1[8] = {1,2,3,4,5,6,7,8};
    uint16_t vectorOut1[8] = {0,0,0,0,0,0,0,0};
    uint16_t vectorOut2[8] = {0,0,0,0,0,0,0,0};
    uint16_t vectorOut3[8] = {0,0,0,0,0,0,0,0};

    RESET_CYCLES;
    asm_productoEscalar12(vectorIn1,vectorOut1,8,1000);
    printf("asm_productoEscalar12 : %d ciclos\n\r", GET_CYCLES);

    RESET_CYCLES;
    asm_productoEscalar12_sat(vectorIn1,vectorOut2,8,1000);
    printf("asm_productoEscalar12_sat : %d ciclos\n\r", GET_CYCLES);
    
    RESET_CYCLES;
    c_productoEscalar12(vectorIn1,vectorOut2,8,1000);
    printf("c_productoEscalar12 : %d ciclos\n\r", GET_CYCLES);
}

static void productoEscalar16(void)
{
    printf("\n\rEjercicio 3:\n\r");
    uint16_t vectorIn1[8] = {1,2,3,4,5,6,7,8};
    uint16_t vectorOut1[8] = {0,0,0,0,0,0,0,0};
    uint16_t vectorIn2[8] = {1,2,3,4,5,6,7,8};
    uint16_t vectorOut2[8] = {0,0,0,0,0,0,0,0};

    RESET_CYCLES;
    asm_productoEscalar16(vectorIn1,vectorOut1,8,3);
    printf("productoEscalar12 ASM : %d ciclos\n\r", GET_CYCLES);
    
    RESET_CYCLES;
    c_productoEscalar16(vectorIn2,vectorOut2,8,3);
    printf("productoEscalar12 C : %d ciclos\n\r", GET_CYCLES);
}

static void productoEscalar32(void)
{
    printf("\n\rEjercicio 2:\n\r");
    uint32_t vectorIn1[8] = {1,2,3,4,5,6,7,8};
    uint32_t vectorOut1[8] = {0,0,0,0,0,0,0,0};
    uint32_t vectorIn2[8] = {1,2,3,4,5,6,7,8};
    uint32_t vectorOut2[8] = {0,0,0,0,0,0,0,0};

    RESET_CYCLES;
    asm_productoEscalar32(vectorIn1,vectorOut1,8,3);
    printf("productoEscalar32 ASM : %d ciclos\n\r", GET_CYCLES);

    RESET_CYCLES;
    c_productoEscalar32(vectorIn2,vectorOut2,8,3);
    printf("productoEscalar32 C : %d ciclos\n\r", GET_CYCLES);
}

static void Zeros(void)
{
    printf("\n\rEjercicio 1:\n\r");
    uint32_t vector1[8] = {(u_int32_t)-1, (u_int32_t)-2, (u_int32_t)-3,
                           (u_int32_t)-4, (u_int32_t)-5, (u_int32_t)-6,
                           (u_int32_t)-7, (u_int32_t)-8};
    uint32_t vector2[8] = {(u_int32_t)-1, (u_int32_t)-2, (u_int32_t)-3,
                           (u_int32_t)-4, (u_int32_t)-5, (u_int32_t)-6,
                           (u_int32_t)-7, (u_int32_t)-8};
    
    RESET_CYCLES;
    asm_zeros(vector1,8);
    printf("zeros ASM : %d ciclos\n\r", GET_CYCLES);

    RESET_CYCLES;
    c_zeros(vector2,8);
    printf("zeros C : %d ciclos\n\r", GET_CYCLES);
}

static void Suma (void)
{
    const uint32_t A = 20;
    const uint32_t B = 30;

    const uint32_t SumResult_C = c_sum (A, B);
    const uint32_t SumResult_Asm = asm_sum (A, B);

    // Actividad de debug: SumResult_C y SumResult_Asm deberian contener el
    // mismo valor.
    __BKPT (0);

    (void) SumResult_C;
    (void) SumResult_Asm;
}


static void LlamandoAMalloc (void)
{
    // De donde saca memoria malloc?
    // (se vera en clase)
    void * ptr = malloc (2048);

    (void) ptr;
}


static void PrivilegiosSVC (void)
{
    // Obtiene valor del registro de 32 bits del procesador llamado "control".
    // El registro guarda los siguientes estados:
    // bit 2: Uso de FPU en el contexto actual. Usado=1, no usado=0.
    // bit 1: Mapeo del stack pointer(sp). MSP=0, PSP=1.
    // bit 0: Modo de ejecucion en Thread. Privilegiado=0, No privilegiado=1.
    //        Recordar que este valor solo se usa en modo Thread. Las
    //        interrupciones siempre se ejecutan en modo Handler con total
    //        privilegio.
    uint32_t x = __get_CONTROL ();  /* Intrinsic del CMSIS que permite trabajar cosas del procesador de bajo nivel en C */
                                    /* MRS r0, CONTROL */
    // Actividad de debug: Ver registro "control" y valor de variable "x".
    __BKPT (0);

    x |= 1;
    // bit 0 a modo No privilegiado.
    __set_CONTROL (x);

    // En este punto se estaria ejecutando en modo No privilegiado.
    // Lectura del registro "control" para confirmar.
    x = __get_CONTROL ();

    // Actividad de debug: Ver registro "control" y valor de variable "x".
    __BKPT (0);

    x &= ~1u;
    // Se intenta volver a modo Privilegiado (bit 0, valor 0).
    __set_CONTROL (x);

    // Confirma que esta operacion es ignorada por estar ejecutandose en modo
    // Thread no privilegiado.
    x = __get_CONTROL ();

    // Actividad de debug: Ver registro "control" y valor de variable "x".
    __BKPT (0);

    // En este punto, ejecutando en modo Thread no privilegiado, la unica forma
    // de volver a modo privilegiado o de realizar cualquier cambio que requiera
    // modo privilegiado, es pidiendo ese servicio a un hipotetico sistema
    // opertivo de tiempo real.
    // Para esto se invoca por software a la interrupcion SVC (Supervisor Call)
    // utilizando la instruccion "svc".
    // No hay intrinsics para realizar esta tarea. Para utilizar la instruccion
    // es necesario implementar una funcion en assembler. Ver el archivo asm_func.S.
    asm_svc ();

    // El sistema operativo (el handler de SVC) deberia haber devuelto el modo
    // de ejecucion de Thread a privilegiado (bit 0 en valor 0).
    x = __get_CONTROL ();

    // Fin del ejemplo de SVC
}


// Handler de la interrupcion "SVC" (Supervisor Call).
// Usado por el ejemplo "EjemploPrivilegiosSVC".
// Me pasa al modo privilegiado.
// Únicamente se puede volver al modo privilegiado a través de una interrupción.
void SVC_Handler (void)
{
    // Se obtiene el valor del registro "control". El bit 0 indica el nivel
    // de privilegio en modo "Thread". Deberia ser 1: No privilegiado.
    uint32_t x = __get_CONTROL ();

    // Borra el bit 0. Nuevo valor 0: privilegiado.
    x &= ~1u;

    // Asigna el nuevo valor al registro "control". Esta operacion deberia
    // ejecutarse ya que todo manejador de interrupciones se ejecuta en modo
    // "Handler" con total privilegio.
    __set_CONTROL (x);
}


noreturn void LoopInfinito (void)
{
    while (1)
    {
        // Procesador en modo espera hasta que ocurra una interrupcion
        // (Bajo consumo)
        __WFI();
    }
}


int main (void)
{
    ENABLE_DWT;

    Inicio ();

    Zeros(); //Ejercicio 1

    productoEscalar32(); //Ejercicio 2

    productoEscalar16(); //Ejercicio 3

    productoEscalar12(); //Ejercicio 4

    filtroVentana10(); //Ejercicio 5

    pack32to16(); //Ejercicio 6

    max(); //Ejercicio 7

    invertir(); //Ejercicio 9

    eco(); //Ejercicio 10
    
    //Suma ();

    //PrivilegiosSVC ();

    //LlamandoAMalloc ();

    LoopInfinito ();

}
