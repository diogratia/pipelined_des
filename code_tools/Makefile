
# C sourced C99 compatible.

SBOXES = sbox1.vhdl sbox2.vhdl sbox3.vhdl sbox4.vhdl sbox5.vhdl sbox6.vhdl \
         sbox7.vhdl sbox8.vhdl

VECTORS = input_vector.vhdl key_vector.vhdl output_vector.vhdl \
          encrypt_vector.vhdl

all: sbox_lookup desvec64
	sbox_lookup	 
	desvec64 -i des.test

desvec64: desvec64.c
	$(CC) desvec64.c -o desvec64

sbox_lookup: sbox_lookup.c
	$(CC) sbox_lookup.c -o sbox_lookup 

clean:
	-\rm -rf desvec64 sbox_lookup $(SBOXES) $(VECTORS)
	