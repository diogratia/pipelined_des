#include <stdio.h>
#include <stdint.h>
#define IS_BIG_ENDIAN (!*(unsigned char *)&(uint16_t){1})

int main () 
{
    printf("%s\n", IS_BIG_ENDIAN?"BIG ENDIAN":"LITTLE ENDIAN");
    return (0);
}