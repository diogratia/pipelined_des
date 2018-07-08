#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#define MAX_VECTOR 512

void rom_header (rom_name,array_size)
char *rom_name;
int array_size;
{
    printf("library ieee;\nuse ieee.std_logic_1164.all;\n");
    printf("\nentity %s is\n    port (\n",rom_name);
    printf("\tindex:\t\tin     integer range 0 to %d;\n",array_size*8-1);
    printf("\tOE:\t\tin     std_logic;\n");
    printf("\toutput:\t\tout    std_logic_vector (7 downto 0)\n");
    printf("    );\nend ;\n");
    printf("\narchitecture behave of %s is\n\n",rom_name);
    printf("    subtype bytestring is bit_vector( 7 downto 0);\n");
    printf("    type bytestream is array (0 to %d) of bytestring;\n\n",
        array_size*8-1);
    printf("    constant byte_array:\tbytestream := (\n\t    ");
}

void rom_tail() {
    printf("    begin\n\n");
    printf("    output <= To_StdLogicVector(byte_array(index)) ");
    printf("when OE = '1' else\n");
    printf("              (others => 'Z')                      ");
    printf("when OE = '0' else\n");
    printf("              (others => 'X');\n");
    printf("\n\nend behave;\n\n");
}

int main (argc,argv) 
int argc;
char *argv[];
{
extern char *optarg;
extern int optind, opterr;
extern int getopt();

char *infile;
char key_vector[MAX_VECTOR][16];
char plain_vector[MAX_VECTOR][16];
char cipher_vector[MAX_VECTOR][16];
char testinput[2047];
char testkey[17];
char testplain[17];
char testcipher[17];

int encrypt[MAX_VECTOR];
int i;
int len;
int testcount = 0;
int totalcount = 0;
int linenumber = 0;
int vector = 0;
int encode = 1;

    while ( (i=getopt(argc,argv,"i:")) != -1 )  {
        switch (i) {
        case 'i':
            infile = optarg;
            if((freopen(optarg,"r",stdin)) == NULL) {
                fprintf(stderr,"ERROR:%s, can't open %s for input\n",
                        argv[0],optarg);
                exit(-1);
            }
        break;
        case '?':
            fprintf(stderr,"usage: %s [-i infile] \n",argv[0]);
            fprintf(stderr,"\ngenerates VHDL arrays for DES test vectors:\n");
            fprintf(stderr,"\tcipher_vector.vhdl\n");
            fprintf(stderr,"\tencrypt_vector.vhdl\n");
            fprintf(stderr,"\tkey_vector.vhdl\n");
            fprintf(stderr,"\tplain_vector.vhdl\n");
            exit (-1);
        break;
        }
    }
        
    while (fgets(testinput,(sizeof testinput) -1, stdin) != NULL ) {

    linenumber++;
    if ( strncmp(testinput,"encrypt",7) == 0) { /* mode = encode */
        encode = 1;
            fprintf(stderr,"%s",testinput);
       }
        else
        if ( strncmp(testinput,"decrypt",7) == 0) { /* mode = decode */
            fprintf(stderr,"%s",testinput);
        encode = 0;
        }
        else 
        if ( strncmp(testinput," ",1) == 0) { /* key, plain & cipher */
        testcount++;
            len = sscanf(testinput,"%s%s%s*", testkey, testplain, testcipher);
            if (len != 3) {
                fprintf(stderr,"ERROR: %s, wrong vector count, line %d\n",
                    argv[0], linenumber);
                exit(-1);
            }
            else if (strlen(testkey) != 16) {
                fprintf(stderr,"ERROR: %s wrong byte count testkey, line %d\n",
                    argv[0],linenumber);
                exit(-1);
        }
            else if (strlen(testplain) != 16) {
                fprintf(stderr,"ERROR: %s wrong byte count testplain, line %d\n",
                    argv[0],linenumber);
                exit(-1);
            }
            else if (strlen(testcipher) != 16) {
                fprintf(stderr,"ERROR: %s wrong byte count testcipher, line %d\n",
                    argv[0],linenumber);
                exit(-1);
            }
            else {
                encrypt[vector] = encode;
                strncpy(   key_vector[vector],   testkey,16);
                strncpy( plain_vector[vector], testplain,16);
                strncpy(cipher_vector[vector],testcipher,16);

                for ( i = 0; i < 16; i++) {
                    if ( !isxdigit(key_vector[vector][i]) ||
                         !isxdigit(plain_vector[vector][i]) ||
                         !isxdigit(cipher_vector[vector][i]) ) {
                    fprintf(stderr,"ERROR: %s, Vector: %d contains nonhex\n",
                        argv[0], vector+1);
                    fprintf(stderr,"\t%s\n",testinput);
                        exit(-1);
                    }
                }
            }
            vector++;
            if (vector == MAX_VECTOR) {
                fprintf(stderr,"%s: Maximum number of vectors = %d\n",
                    argv[0],MAX_VECTOR);
                exit(0);
            }
        }
    else {                                /* nothing but eyewash */
            if ( testcount ) {
        fprintf(stderr," %d test vectors\n",testcount);
                totalcount +=testcount;
                testcount = 0;
            }
        }
    }
    fprintf(stderr," Total: %d test vectors\n",totalcount);

    if (freopen("key_vector.vhdl","w",stdout) == NULL){
        fprintf(stderr,"ERROR: %s can write to key_vector.vhdl\n",argv[0]);
        exit (-1);
    } 
    rom_header("key_vector",totalcount);
    for(vector = 0; vector < totalcount; vector++) {
 
        for ( i = 0; i <= 15; i++) {
            if ( !(i & 1)) {
                printf("x\"%c",key_vector[vector][i]);
            }
            else {
                if ( i < 15) {
                    printf("%c\",",key_vector[vector][i]);
                }
                else {
                    printf("%c\"",key_vector[vector][i]); // no comma
                }
            } 
        }
        if (vector != totalcount-1) 
            printf(",\n\t    ");
        else
            printf("\n\t);\n");
    }    
    rom_tail();

    if (freopen("plain_vector.vhdl","w",stdout) == NULL){
        fprintf(stderr,"ERROR: %s can write to plain_vector.vhdl\n",argv[0]);
        exit (-1);
    } 
    rom_header("plain_vector",totalcount);
    for(vector = 0; vector < totalcount; vector++) {

        for ( i = 0; i <= 15; i++) {
            if ( !(i & 1)) {
                printf("x\"%c",plain_vector[vector][i]);
            }
            else {
                if ( i < 15) {
                    printf("%c\",",plain_vector[vector][i]);
                }
                else {
                    printf("%c\"",plain_vector[vector][i]); // no comma
                }
            } 
        }
        if (vector != totalcount-1) 
            printf(",\n\t    ");
        else
            printf("\n\t);\n");
    }    
    rom_tail();

    if (freopen("cipher_vector.vhdl","w",stdout) == NULL){
        fprintf(stderr,"ERROR: %s can write to cipher_vector.vhdl\n",argv[0]);
        exit (-1);
    } 
    rom_header("cipher_vector",totalcount);
    for(vector = 0; vector < totalcount; vector++) {

        for ( i = 0; i <= 15; i++) {
            if ( !(i & 1)) {
                printf("x\"%c",cipher_vector[vector][i]);
            }
            else {
                if ( i < 15) {
                    printf("%c\",",cipher_vector[vector][i]);
                }
                else {
                    printf("%c\"",cipher_vector[vector][i]); // no comma
                }
            } 
        }
        if (vector != totalcount-1) 
            printf(",\n\t    ");
        else
            printf("\n\t);\n");
    }    
    rom_tail();

    if (freopen("encrypt_vector.vhdl","w",stdout) == NULL){
        fprintf(stderr,"ERROR: %s can write to encrypt_vector.vhdl\n",argv[0]);
        exit (-1);
    } 
    printf("library ieee;\nuse ieee.std_logic_1164.all;\n");
    printf("\nentity encrypt_vector is\n    port (\n");
    printf("\tindex:\t\tin     integer range 0 to %d;\n",totalcount-1);
    printf("\toutput:\t\tout    std_logic\n");
    printf("    );\nend ;\n");
    printf("\narchitecture behave of encrypt_vector is\n\n");
    printf("    constant bit_array:\tstd_logic_vector(0 to %d) := (\n\t    ",
            totalcount-1);

    i = 0;
    for(vector = 0; vector < totalcount; vector++) {
    printf("'%1d'",encrypt[vector]);i++;
    if ((i == 16) && (vector != totalcount-1)) {
        printf(",\n\t    ");
        i = 0;
    }
    else if (vector == totalcount-1)
        printf("\n\t);\n");
    else
        printf(",");
    }    
    printf("    begin\n\n");
    printf("    output <= bit_array(index);");
    printf("\n\nend behave;\n\n");

    exit (0);
}

