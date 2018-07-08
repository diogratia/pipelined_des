library ieee;
use ieee.std_logic_1164.all;

entity frk is
    port (
        R:      in  std_logic_vector (1 to 32);
        K:      in  std_logic_vector (1 to 48);
        P:      out std_logic_vector (1 to 32)
    
    );
end entity;


architecture foo of frk is
    signal B:   std_logic_vector (1 to 48);
    signal PO:  std_logic_vector (1 to 32);
begin
    
-- E Permutation
--
-- R(32)   R(1)    R(2)    R(3)    R(4)    R(5)        S1
-- R(4)    R(5)    R(6)    R(7)    R(8)    R(9)        S2
-- R(8)    R(9)    R(10)   R(11)   R(12)   R(13)       S3
-- R(12)   R(13)   R(14)   R(15)   R(16)   R(17)       S4
-- R(16)   R(17)   R(18)   R(19)   R(20)   R(21)       S5
-- R(20)   R(21)   R(22)   R(23)   R(24)   R(25)       S6
-- R(24)   R(25)   R(26)   R(27)   R(28)   R(29)       S7
-- R(28)   R(29)   R(30)   R(31)   R(32)   R(1)        S8

-- E(R) xor K
--
    B <= R(32) & R(1 to 5) & R(4 to 9) & R(8 to 13) & R(12 to 17 ) &
         R(16 to 21) & R(20 to 25) & R(24 to 29) & R(28 to 32) & R(1)
         xor K;

-- The 48 bits of selected key are XORed from left to right with E(R) as 
-- inputs to the 8 SBoxes

-- The C and D register each provide 24 bits of K through the PC2 Permuted 
-- Choice 2 selection permutation XOR's with E and input to the S Boxes.
-- 
-- The C register outputs are used in S1 - S4, the D register outputs S5 - S8

S1:
    entity work.sbox1 
        port map (
            B   => B(1 to 6),
            S   => PO(1 to 4)
        );

S2:
    entity work.sbox2 
        port map (
            B   => B(7 to 12),
            S   => PO(5 to 8)
        );

S3:
    entity work.sbox3 
        port map (
            B   => B(13 to 18),
            S   => PO(9 to 12)
        );

S4:
    entity work.sbox4 
        port map (
            B   => B(19 to 24),
            S   => PO(13 to 16)
        );

S5:
    entity work.sbox5
        port map (
            B   => B(25 to 30),
            S   => PO(17 to 20)
        );

S6:
    entity work.sbox6
        port map (
            B   => B(31 to 36),
            S   => PO(21 to 24)
        );

S7:
    entity work.sbox7
        port map (
            B   => B(37 to 42),
            S   => PO(25 to 28)
        );

S8:
    entity work.sbox8
        port map (
            B   => B(43 to 48),
            S   => PO(29 to 32)
        );

-- An SBox is comprised of four rows of 16 values. The Row addresses is from 
-- the leftmost E xor K value (Row Address 1) and the rightmost E xor K value
-- (Row Address 0). The middle four are Column Address 3 downto 0, left to 
-- right.

-- The 32 bits of output from SBox 1 to 8 left to right are the inputs to the P permutation.
P_PERM:
    process(PO)
    begin
        P(1)  <= PO(16); P(2)  <= PO(7);  P(3)  <= PO(20); P(4)  <= PO(21);
        P(5)  <= PO(29); P(6)  <= PO(12); P(7)  <= PO(28); P(8)  <= PO(17);
        P(9)  <= PO(1);  P(10) <= PO(15); P(11) <= PO(23); P(12) <= PO(26);
        P(13) <= PO(5);  P(14) <= PO(18); P(15) <= PO(31); P(16) <= PO(10);
        P(17) <= PO(2);  P(18) <= PO(8);  P(19) <= PO(24); P(20) <= PO(14);
        P(21) <= PO(32); P(22) <= PO(27); P(23) <= PO(3);  P(24) <= PO(9);
        P(25) <= PO(19); P(26) <= PO(13); P(27) <= PO(30); P(28) <= PO(6);
        P(29) <= PO(22); P(30) <= PO(11); P(31) <= PO(4);  P(32) <= PO(25);
    end process;
end architecture;
    