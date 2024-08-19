LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.ALL;

entity DDS_SIN_COS_GENERATOR_TB is
	-- Generic declarations of the tested unit
		generic(
	   out_WIDTH : positive := 16;    -- output sinusoid width (IP CORE fixed at 16 bits)
	   pacc_WIDTH : positive := 16;   -- phase accumulator width (IP CORE fixed at 16 bits) 
	   cnt_WIDTH : positive := 16;    -- phase accumulator counter width
	   pinc_WIDTH : positive := 16    -- phase increment width -> same as counter
	   );
end DDS_SIN_COS_GENERATOR_TB;

architecture TB of DDS_SIN_COS_GENERATOR_TB is
	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : std_logic := '0';
	signal reset: std_logic;
	signal freq_value : std_logic_vector(pinc_WIDTH - 1 downto 0);
	signal load_freq : std_logic;
	signal phase_offset : std_logic_vector(cnt_width - 1 downto 0);
    signal sine_out : std_logic_vector(out_WIDTH - 1 downto 0);
    signal cosine_out : std_logic_vector(out_WIDTH - 1 downto 0);		
    signal M_AXIS_tvalid : std_logic;
    signal S_AXIS_tvalid : std_logic;

	constant period : time := 10 ns;
begin
	-- Unit Under Test port map
	UUT : entity DDS_SIN_COS_GENERATOR
		  generic map (out_WIDTH => out_WIDTH, pacc_WIDTH => pacc_WIDTH, cnt_WIDTH => cnt_WIDTH, pinc_WIDTH => pinc_WIDTH)
		  port map (
			 clk => clk,
			 reset => reset,
			 freq_value => freq_value,
			 load_freq => load_freq,
			 phase_offset => phase_offset,
			 sine_out => sine_out,
			 cosine_out => cosine_out,
             M_AXIS_tvalid => M_AXIS_tvalid,
             S_AXIS_tvalid => S_AXIS_tvalid);
	
	  S_AXIS_tvalid <= '1';
	
	-- insert integer value to observe a particular frequency
	freq_value <= std_logic_vector(to_unsigned(2**13,pinc_WIDTH)), std_logic_vector(to_unsigned(2**6,pinc_WIDTH)) after 1000 * period;
	phase_offset <= (others => '0');
	
	load_freq <= '0', '1' after 7 * period, '0' after 10 * period, '1' after 999 * period, '0' after 1008*period;
		
	reset <= '1', '0' after 5 * period;	-- reset signal
	
	clock: process				-- system clock
	begin
        clk <= '0';
        wait for period/2;
        clk <= '1';
        wait for period/2;
	end process;
end TB;