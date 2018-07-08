library ieee;
use ieee.std_logic_1164.all;

entity pipelined_des_tb is
end entity;

architecture foo of pipelined_des_tb is
    signal clk:         std_logic := '0';
    signal reset:       std_logic;
    signal validi:      std_logic;
    signal encodei:     std_logic;
    signal input:       std_logic_vector (1 to 64);
    signal key:         std_logic_vector (1 to 64);
    signal valido:      std_logic;
    signal encodeo:     std_logic;
    signal output:      std_logic_vector (1 to 64);
    signal ref_out:     std_logic_vector (1 to 64);
    signal in_index:    positive range 1 to 291 := 1;
    signal out_index:   positive range 1 to 291 := 1;
begin

input_vectors:
    entity work.input_vector
        port map (
            index => in_index,
            output => input
        );

key_vectors:
    entity work.key_vector
        port map (
            index => in_index,
            output => key
        );

output_vectors:
    entity work.output_vector
        port map (
            index => out_index,
            output => ref_out
        );

encrypt_vectors:
    entity work.encrypt_vector
        port map (
            index => in_index,
            output => encodei
        );

DUT:
    entity work.pipelined_des
        port map (
            clk => clk,
            reset => reset,
            validi => validi,
            encodei => encodei,
            input => input,
            key => key,
            valido => valido,
            encodeo => encodeo,
            output => output
        );
CLOCK:
    process
    begin
        wait for 10 ns;
        clk <= not clk;
        if now > 6190 ns then
            wait;
        end if;
    end process;
ZEROIZE:
    process
    begin
        wait for 20 ns;
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait;
    end process;
    
VALID:
    process (clk, reset)
    begin
        if reset = '1' then
            validi <= '1';
        elsif rising_edge(clk) then
            if in_index = 291 then
                validi <= '0';
            end if;
        end if;
    end process;

INPUT_INDEX:
    process (clk, reset)
    begin
        if reset = '1' then
            in_index <= 1;
        elsif rising_edge(clk) then
            if in_index /= 291 and validi = '1' then
                in_index <= in_index + 1;
            end if;
        end if;
    end process;

OUTPUT_INDEX:
    process (clk, reset)
    begin
        if reset = '1' then
            out_index <= 1;
        elsif rising_edge(clk) then
            if out_index /= 291  and valido = '1' then
                out_index <= out_index + 1;
            end if;
        end if;
    end process;
    
MONITOR:
    process
    begin
        wait until falling_edge(clk); -- convenient sample point, 
        if valido = '1' then          -- zero time model
            assert output = ref_out
                report "out_index " & integer'image(out_index)
                severity ERROR;
        end if;
    end process;
end architecture;
    