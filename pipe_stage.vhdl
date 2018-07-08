library ieee;
use ieee.std_logic_1164.all;

entity pipe_stage is
    generic (
        constant SHIFT: natural range 1 to 2 := 1
    );
    port (
        clk:    in  std_logic;
        reset:  in  std_logic;
        valid:  in  std_logic;
        encode: in  std_logic;
        R:      in  std_logic_vector (1 to 32);
        L:      in  std_logic_vector (1 to 32);
        C:      in  std_logic_vector (1 to 28);
        D:      in  std_logic_vector (29 to 56);
        Ri:     out std_logic_vector (1 to 32);
        Li:     out std_logic_vector (1 to 32);
        Ci:     out std_logic_vector (1 to 28);
        Di:     out std_logic_vector (29 to 56);
        val:    out std_logic;
        enc:    out std_logic
    );
end entity;

architecture foo of pipe_stage is
    signal P:   std_logic_vector (1 to 32);
    signal K:   std_logic_vector (1 to 48);
    signal CR:  std_logic_vector (1 to 28);
    signal DR:  std_logic_vector (29 to 56);
    signal CL:  std_logic_vector (1 to 28);
    signal DL:  std_logic_vector (29 to 56);
begin

PC2C:
    process (C)  -- C(9), C(18), C(22) and C(25) not used
    begin
        K(1)  <= C(14); K(2)  <= C(17); K(3)  <= C(11); K(4)  <= C(24);
        K(5)  <= C(1);  K(6)  <= C(5);  K(7)  <= C(3);  K(8)  <= C(28);
        K(9)  <= C(15); K(10) <= C(6);  K(11) <= C(21); K(12) <= C(10);
        K(13) <= C(23); K(14) <= C(19); K(15) <= C(12); K(16) <= C(4);
        K(17) <= C(26); K(18) <= C(8);  K(19) <= C(16); K(20) <= C(7);
        K(21) <= C(27); K(22) <= C(20); K(23) <= C(13); K(24) <= C(2);
    end process;

PC2D:
    process (D)   -- D(7), D(10), D(15) and D(26) not used
    begin
        K(25) <= D(41); K(26) <= D(52); K(27) <= D(31); K(28) <= D(37);
        K(29) <= D(47); K(30) <= D(55); K(31) <= D(30); K(32) <= D(40);
        K(33) <= D(51); K(34) <= D(45); K(35) <= D(33); K(36) <= D(48);
        K(37) <= D(44); K(38) <= D(49); K(39) <= D(39); K(40) <= D(56);
        K(41) <= D(34); K(42) <= D(53); K(43) <= D(46); K(44) <= D(42);
        K(45) <= D(50); K(46) <= D(36); K(47) <= D(29); K(48) <= D(32);
    end process;

f_R_K:
    entity work.frk
        port map (
            R => R,
            K => K,
            P => P
        );

SHFT_1:
    if SHIFT = 1 generate
        CL <= C(2 to 28) & C(1);
        CR <= C(28) & C(1 to 27);
        DL <= D(30 to 56) & D(29);
        DR <= D(56) & D(29 to 55);
    end generate;

SHFT_2:
    if SHIFT = 2 generate
        CL <= C(3 to 28) & C(1 to 2);
        CR <= C(27 to 28) & C(1 to 26);
        DL <= D(31 to 56) & D(29 to 30);
        DR <= D(55 to 56) & D(29 to 54);
    end generate;
    
PIPE_REGS:
    process (clk, reset)
    begin
        if reset = '1' then
            Li <= (others => '0');
            Ri <= (others => '0');
            Ci <= (others => '0');
            Di <= (others => '0');
            val <= '0';
            enc <= '0';
        elsif rising_edge(clk) then
            Ri <= P xor L;
            Li <= R;
            if encode = '1' then  -- encryption shift left
                Ci <= CL;
                Di <= DL;
            else                  -- decryption shift right
                Ci <= CR;
                Di <= DR;
            end if;
            val <= valid;
            enc <= encode;
        end if;
    end process;
end architecture;
    