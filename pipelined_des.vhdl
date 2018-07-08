library ieee;
use ieee.std_logic_1164.all;

entity pipelined_des is
    port (
        clk:        in  std_logic;
        reset:      in  std_logic;
        validi:     in  std_logic;
        encodei:    in  std_logic;
        input:      in  std_logic_vector (1 to 64);
        key:        in  std_logic_vector (1 to 64);
        valido:     out std_logic;
        encodeo:    out std_logic;
        output:     out std_logic_vector (1 to 64)
    );
end entity;

architecture foo of pipelined_des is
    -- wires, lots of wires:
    type LR is array (0 to 16) of std_logic_vector (1 to 32);
    signal R:       LR;
    signal L:       LR;
    signal PC1C:    std_logic_vector(1 to 28);
    signal PC1D:    std_logic_vector(1 to 28);
    type C_D is array (1 to 16) of std_logic_vector (1 to 56);
    signal CD:      C_D;
    type stage is array (0 to 16) of std_logic;
    signal val:     stage;
    signal enc:     stage;
    signal R16L16:  std_logic_vector(1 to 64);
    type shiftsched is array (0 to 15) of natural range 1 to 2;
    constant KEYSCHED: shiftsched :=  -- offset for encrypt preshift
          (1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1);
    
    -- The Ci, Di Register outputs of Feistal STAGE 16 aren't used. The 
    -- extra shift doesn't matter.
    
    -- With the offset in shiftsched index and the preshift for encrypt we
    -- traverse the same shift schedule for encrypt and decrypt, The last
    -- shift to restore the state of C and D isn't needed when descrypting, 
    -- a Triple DES would use a different key load for the next 16 stage 
    -- pipeline. The last stage shift (for decrypt) has been removed from
    -- last_stage.vhdl.
    
begin
    
    
    -- PERMUTED CHOICE 1
    
    PC1C <= key(57) & key(49) & key(41) & key(33) &
            key(25) & key(17) & key(9)  & key(1)  &
            key(58) & key(50) & key(42) & key(34) &
            key(26) & key(18) & key(10) & key(2)  &
            key(59) & key(51) & key(43) & key(35) &
            key(27) & key(19) & key(11) & key(3)  &
            key(60) & key(52) & key(44) & key(36);
            
    PC1D <= key(63) & key(55) & key(47) & key(39) &
            key(31) & key(23) & key(15) & key(7)  &
            key(62) & key(54) & key(46) & key(38) &
            key(30) & key(22) & key(14) & key(6)  &
            key(61) & key(53) & key(45) & key(37) &
            key(29) & key(21) & key(13) & key(5)  &
            key(28) & key(20) & key(12) & key(4);
    
    -- PARITY?
    
-- Stage 0 input register to cover Key Schedule preshift multiplexer
-- (critical path is K xor E(R) -> P(SBOX) xor L. 
-- Adding the mux to the first FEISTAL Stage would limit throughput, 
-- while an input register only adds one clock latency.)
    
-- set up inputs:
STAGE_0:
    process (clk, reset)
    begin
        if reset = '1' then
            val(0) <= '0';
            enc(0) <= '0';
            R(0) <= (others => '0');
            L(0) <= (others => '0');
            CD(1) <= (others => '0');
        elsif rising_edge(clk) then
            val(0) <= validi;
            enc(0) <= encodei;
            
        -- INITIAL PERMUTATION  (big endian input block)
        
            L(0) <= input(58) & input(50) & input(42) & input(34) & 
                    input(26) & input(18) & input(10) & input(2)  &
                    input(60) & input(52) & input(44) & input(36) &
                    input(28) & input(20) & input(12) & input(4)  &
                    input(62) & input(54) & input(46) & input(38) &
                    input(30) & input(22) & input(14) & input(6)  &
                    input(64) & input(56) & input(48) & input(40) &
                    input(32) & input(24) & input(16) & input(8);
                    
            R(0) <= input(57) & input(49) & input(41) & input(33) & 
                    input(25) & input(17) & input(9)  & input(1)  &
                    input(59) & input(51) & input(43) & input(35) &
                    input(27) & input(19) & input(11) & input(3)  &
                    input(61) & input(53) & input(45) & input(37) &
                    input(29) & input(21) & input(13) & input(5)  &
                    input(63) & input(55) & input(47) & input(39) &
                    input(31) & input(23) & input(15) & input(7);
        
        -- the PC1 to C,D includes a preshift if encrypting
            if  encodei = '1' then  -- RIGHT SHIFT
                CD(1)( 1 to 28) <= PC1C(2 to 28) & PC1C(1);
                CD(1)(29 to 56) <= PC1D(2 to 28) & PC1D(1);
            else                   -- decrypt uses K16 loaded by PC1
                CD(1)( 1 to 28) <= PC1C;
                CD(1)(29 to 56) <= PC1D;
            end if;
            -- Stage 0 pipeline registers overcome this 2:1 mux time
        end if;
    end process;

-- PERMUTED CHOICE 1
-- 

FEISTAL_LADDER:               -- first 15 pipeline stages 
    for i in 1 to 15 generate
FEISTAL_STAGE:
        entity work.pipe_stage
            generic map (
                SHIFT => KEYSCHED(i)
            )
            port map (
                clk    => clk,
                reset  => reset,
                valid  => val(i - 1),
                encode => enc(i - 1),
                R      => R(i - 1),
                L      => L(i - 1),
                C      => CD(i)(1 to 28),
                D      => CD(i)(29 to 56),
                Ri     => R(i),
                Li     => L(i),
                Ci     => CD(i + 1)(1 to 28),
                Di     => CD(i + 1)(29 to 56),
                val    => val(i),
                enc    => enc(i)
            );
    end generate;
FEISTAL_LAST:
    entity work.last_stage
        port map (
            clk    => clk,
            reset  => reset,
            valid  => val(15),
            encode => enc(15),
            R      => R(15),
            L      => L(15),
            C      => CD(16)(1 to 28),
            D      => CD(16)(29 to 56),
            Ri     => R(16),
            Li     => L(16),
            val    => val(16),
            enc    => enc(16)
        );

    R16L16 <= R(16) & L(16);
    
-- OUTPUTS:

    valido <= val(16);
    encodeo <= enc(16);
    
-- INVERSE INITIAL PERMUATION (IP-1) (big endian output block)

   output <=  R16L16(40) & R16L16(8)  & R16L16(48) & R16L16(16) &
              R16L16(56) & R16L16(24) & R16L16(64) & R16L16(32) &
              R16L16(39) & R16L16(7)  & R16L16(47) & R16L16(15) &
              R16L16(55) & R16L16(23) & R16L16(63) & R16L16(31) &
              R16L16(38) & R16L16(6)  & R16L16(46) & R16L16(14) &
              R16L16(54) & R16L16(22) & R16L16(62) & R16L16(30) &
              R16L16(37) & R16L16(5)  & R16L16(45) & R16L16(13) &
              R16L16(53) & R16L16(21) & R16L16(61) & R16L16(29) &
              R16L16(36) & R16L16(4)  & R16L16(44) & R16L16(12) &
              R16L16(52) & R16L16(20) & R16L16(60) & R16L16(28) &
              R16L16(35) & R16L16(3)  & R16L16(43) & R16L16(11) &
              R16L16(51) & R16L16(19) & R16L16(59) & R16L16(27) &
              R16L16(34) & R16L16(2)  & R16L16(42) & R16L16(10) &
              R16L16(50) & R16L16(18) & R16L16(58) & R16L16(26) &
              R16L16(33) & R16L16(1)  & R16L16(41) & R16L16(9)  &
              R16L16(49) & R16L16(17) & R16L16(57) & R16L16(25);
   
   
end architecture;
    