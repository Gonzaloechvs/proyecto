#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

int32_t calcula_alu(int32_t A,int32_t B,int sel_fn)
{
    int32_t resultado=0;

    switch (sel_fn)
    {
    // suma
    case 0b0000:
        resultado = A + B;
        break;
    // resta
    case 0b0001:
        resultado = A - B;
        break;
    // desplazamiento a la izquierda
    case 0b0010: // FALLTHROUGH
    case 0b0011:
        resultado = (int32_t)((uint32_t)A << (B & 0b11111));
        break;
    // menor con signo
    case 0b0100: // FALLTHROUGH
    case 0b0101:
        resultado = A < B;
        break;
    // menor sin signo
    case 0b0110: // FALLTHROUGH
    case 0b0111:
        resultado = (uint32_t)A < (uint32_t)B;
        break;
    // o exclusivo bit a bit
    case 0b1000: // FALLTHROUGH
    case 0b1001:
        resultado = A ^ B;
        break;
    // desplazamiento logico a la derecha
    case 0b1010:
        resultado = (int32_t)((uint32_t)A >> (B & 0b11111));
        break;
    // desplazamiento aritmético a la derecha
    case 0b1011:
        resultado = A >> (B & 0b11111);
        break;
    // o bit a bit
    case 0b1100: // FALLTHROUGH
    case 0b1101:
        resultado = A | B;
        break;
    // y bit a bit
    case 0b1110: // FALLTHROUGH
    case 0b1111:
        resultado = A & B;
        break;
    default:
        fprintf(stderr,"Selector de funcion no valido %x\n",sel_fn);
        exit(1);
        break;
    }
    return resultado;
}

void genera_vector_prueba(int32_t A,int32_t B,int sel_fn)
{
    int32_t Y = calcula_alu(A,B,sel_fn);
    printf("%08x %08x %x %08x %x\n", A, B, sel_fn, Y, 0 == Y);
}
int32_t randint32(void)
{
    // RAND_MAX es 7fff
    uint32_t a = rand();
    uint32_t b = rand();
    uint32_t c = rand();
    return (int32_t)(a | (b << 15) | (c << 31));
}
int main(void)
{
    enum {SUMA=0b0000, RESTA=0b0001,DESP_IZQ=0b0010,
          MENOR=0b0100,MENOR_SIN_SIGNO=0b0110,O_EXCL=0b1000,
          DESP_DER_LOGICO=0b1010,DESP_DER_ARITMETICO=0b1011,
          O_BIT_A_BIT=0b1100,Y_BIT_A_BIT=0b1110};

    printf("-- A B sel_fn Y Z\n");
    genera_vector_prueba(1,31,DESP_IZQ);
    genera_vector_prueba(-1,31,DESP_DER_LOGICO);
    genera_vector_prueba(-1000000,31,DESP_DER_ARITMETICO);
    genera_vector_prueba(-1,10,MENOR);
    genera_vector_prueba(-1,10,MENOR_SIN_SIGNO);

    for (int i = 0; i < 10000; ++i)
    {
        int32_t A = randint32();
        int32_t B = randint32();
        int sel_fn = rand() & 0b1111;
        genera_vector_prueba(A,B,sel_fn);
    }
    return 0;
}