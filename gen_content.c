#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

//generar un archivo de 512 lineas con vectores de 32bits

int main(void)
{
    FILE *f = fopen("vectors.txt", "w");
    if (f == NULL) {
        fprintf(stderr, "Error opening file\n");
        return 1;
    }

    for (int i = 0; i < 512; i++) {
        uint32_t A = rand();
        fprintf(f, "%08x\n", A);
    }

    fclose(f);
    return 0;
}