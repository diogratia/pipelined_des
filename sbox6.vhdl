library ieee;
use ieee.std_logic_1164.all;

entity sbox6 is
    port (
	B:    in      std_logic_vector (1 to 6);
	S:    out     std_logic_vector (1 to 4)
    );
end ;

architecture behave of sbox6 is

    subtype 	nybble       is std_logic_vector(1 to 4);
    type	nybble_array is array ( 0 to 63) of nybble;

    -- sbox outputs are little endian order

    constant sbox:  nybble_array := (
	"1100", "0001", "1010", "1111", 
	"1001", "0010", "0110", "1000", 
	"0000", "1101", "0011", "0100", 
	"1110", "0111", "0101", "1011", 
	"1010", "1111", "0100", "0010", 
	"0111", "1100", "1001", "0101", 
	"0110", "0001", "1101", "1110", 
	"0000", "1011", "0011", "1000", 
	"1001", "1110", "1111", "0101", 
	"0010", "1000", "1100", "0011", 
	"0111", "0000", "0100", "1010", 
	"0001", "1101", "1011", "0110", 
	"0100", "0011", "0010", "1100", 
	"1001", "0101", "1111", "1010", 
	"1011", "1110", "0001", "0111", 
	"0110", "0000", "1000", "1101"  
	);

begin

OUTPUT:
    process(B)

	variable index:	integer range 0 to 63;

    begin

	index := 0;

	if IS_X(B) then
	    S <= "XXXX";
	else
	    if TO_BIT(B(1)) = '1' then index := 32;         end if;
	    if TO_BIT(B(2)) = '1' then index := index + 8;  end if;
	    if TO_BIT(B(3)) = '1' then index := index + 4;  end if;
	    if TO_BIT(B(4)) = '1' then index := index + 2;  end if;
	    if TO_BIT(B(5)) = '1' then index := index + 1;  end if;
	    if TO_BIT(B(6)) = '1' then index := index + 16; end if;

	    S <= sbox(index);

	end if;
    end process;

end behave;
