library ieee;
use ieee.std_logic_1164.all;

entity sbox2 is
    port (
	B:    in      std_logic_vector (1 to 6);
	S:    out     std_logic_vector (1 to 4)
    );
end ;

architecture behave of sbox2 is

    subtype 	nybble       is std_logic_vector(1 to 4);
    type	nybble_array is array ( 0 to 63) of nybble;

    -- sbox outputs are little endian order

    constant sbox:  nybble_array := (
	"1111", "0001", "1000", "1110", 
	"0110", "1011", "0011", "0100", 
	"1001", "0111", "0010", "1101", 
	"1100", "0000", "0101", "1010", 
	"0011", "1101", "0100", "0111", 
	"1111", "0010", "1000", "1110", 
	"1100", "0000", "0001", "1010", 
	"0110", "1001", "1011", "0101", 
	"0000", "1110", "0111", "1011", 
	"1010", "0100", "1101", "0001", 
	"0101", "1000", "1100", "0110", 
	"1001", "0011", "0010", "1111", 
	"1101", "1000", "1010", "0001", 
	"0011", "1111", "0100", "0010", 
	"1011", "0110", "0111", "1100", 
	"0000", "0101", "1110", "1001"  
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
