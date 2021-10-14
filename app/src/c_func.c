#include "c_func.h"


uint32_t c_sum (uint32_t firstOperand, uint32_t secondOperand)
{
    return (firstOperand + secondOperand);
}

void c_zeros(uint32_t *vector, uint32_t longitud)
{
    for (uint32_t i = 0; i < longitud; i++)
    {
        vector[i] = 0;
    }
}

void c_productoEscalar32(uint32_t *vectorIn, uint32_t *vectorOut, uint32_t longitud, uint32_t escalar)
{
    for (uint32_t i = 0; i < longitud; i++)
    {
        vectorOut[i] = vectorIn[i] * escalar;
    }
}

void c_productoEscalar16(uint16_t *vectorIn, uint16_t *vectorOut, uint32_t longitud, uint16_t escalar)
{
    if (!vectorIn || !vectorOut || !longitud) //Verifico que no sean cero
    {
        return;
    }

    for (uint32_t i = 0; i < longitud; i++)
    {
        vectorOut[i] = vectorIn[i] * escalar;
    }
}

void c_productoEscalar12(uint16_t *vectorIn, uint16_t *vectorOut, uint32_t longitud, uint16_t escalar)
{
    if (!vectorIn || !vectorOut || !longitud) //Verifico que no sean cero
    {
        return;
    }

    for (uint32_t i = 0; i < longitud; i++)
    {
        vectorOut[i] = vectorIn[i] * escalar;
        if (vectorOut[i] > 0xFFF)
        {
            vectorOut[i] = 0xFFF;
        }
    }
}

void c_filtroVentana10(uint16_t *vectorIn, uint16_t *vectorOut, uint32_t longitudVectorIn)
{
#define VENTANA 10
    uint32_t max = 0;
    uint32_t aux = 0;
    for (uint32_t i = 0; i < longitudVectorIn; i++)
    {
        if (i + VENTANA > longitudVectorIn)
        {
            max = longitudVectorIn;
        }
        else
        {
            max = i + VENTANA;
        }
        for (uint32_t j = i; j < max; j++)
        {
            aux += vectorIn[j];
        }
        vectorOut[i] = aux / VENTANA;
    }
}

void c_pack32to16 (int32_t * vectorIn, int16_t *vectorOut, uint32_t longitud)
{
	for(uint32_t i = 0; i < longitud; ++i)
	{
		vectorOut[i] = (uint16_t)(vectorIn[i]>>16); // Se descarta la parte alta del vector de 32 bits
	}
}

int32_t c_max (int32_t * vectorIn, uint32_t longitud)
{
    int32_t mayor = vectorIn[0];
    int32_t pos_mayor = 0;
    for (uint8_t i = 0; i < longitud; i++)
    {
        if(vectorIn[i]>mayor)
        {
            mayor = vectorIn[i];
            pos_mayor = i;
        }
    }
    return pos_mayor;
}

void c_invertir (uint16_t * vector, uint32_t longitud)
{
    uint16_t temp;
    for (uint16_t i = 0; i < longitud / 2; i++)
    {
        temp = vector[i];
        vector[i] = vector[(longitud - 1) - i];
        vector[(longitud - 1) - i] = temp;
    }
}

void c_eco(int16_t *vectorIn)
{
    #define LONG_VECTOR         4096
    #define MUESTRAS_EN_20MS	882     //porque se toman 44,1 muestras/ms

    for (uint16_t i = LONG_VECTOR - 1; i > MUESTRAS_EN_20MS; i--)
    {
        *(vectorIn + i) = *(vectorIn + i) + (*(vectorIn + i - MUESTRAS_EN_20MS)) / 2;
    }
}
