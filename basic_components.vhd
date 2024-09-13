----------------------------------------------------------------------------------
-- MUX
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package data_types is
  type slv_array is array(natural range <>) of std_logic_vector;
end package;

library ieee;
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;
use work.data_types;
      
entity MUX is
  generic(
    WIDTH : positive;   -- Bits in each input
    NUM : positive);  -- Number of inputs
  port(
    data_in : in data_types.slv_array(0 to NUM - 1)(WIDTH - 1 downto 0);
    select_line : in std_logic_vector(NUM - 1 downto 0);
    data_out : out std_logic_vector(WIDTH - 1 downto 0));
end entity;

architecture RTL of MUX is
begin
  data_out <= data_in(to_integer(unsigned(select_line)));
end architecture;


----------------------------------------------------------------------------------
-- DEMUX
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;
use work.data_types;

entity DEMUX is
  generic(
    WIDTH : positive;   -- Bits in each input
    NUM : positive);  -- Number of inputs
  port(
    data_in : out std_logic_vector(WIDTH - 1 downto 0));
    select_line : in std_logic_vector(NUM - 1 downto 0);    
    data_out : in data_types.slv_array(0 to NUM - 1)(WIDTH - 1 downto 0);
end entity;

architecture RTL of MUX is
begin
  gen_label: for i in 0 to NUM generate
    data_out(i) <= data_in when to_integer(unsigned(select_line)) = i else 'Z';
  end generate gen_label;
end architecture;





























library ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.ALL;                       
                          
entity LUT_CONTROLLER is
    generic(data_WIDTH : positive; addr_WIDTH);
    port(
      clk : in std_logic;
      reset : in std_logic;
      load : in std_logic;
      x_in : in std_logic_vector(data_WIDTH - 1 downto 0);
      address : out std_logic_vector(addr_WIDTH - 1 downto 0);
      y_out : out std_logic_vector(data_WIDTH - 1 downto 0);      
      done : out std_logic
    );
end LUT_CONTROLLER

architecture RTL of LUT_CONTROLLER is 
    signal address_counter : integer := 0;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then 
                address_counter <= 0;
                done <= '0';
            elsif load = '1' then 
                address_counter <= address_counter + 1;
                y_out <= x_in;
            end if;
            
            if address_counter = 2**a_WIDTH - 1 then
                done <= '1';
            else
                done <= '0';
            end if;
        end if;    
    end process;
    
    address <= std_logic_vector(to_unsigned(address_counter, data_WIDTH));
end RTL; 
    





----------------------------------------------------------------------------------
-- Multi-stage IIR Decimator
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.ALL;

entity MULTISTAGE_IIR_DECIMATOR is
    generic (data_WIDTH : positive; L : positive; N : integer);
    port(
        clk : in std_logic;	
        reset : in std_logic;					                
        load_coeff : in std_logic;
        stage_ptr : in std_logic_vector(N - 1 downto 0);
        tap : in std_logic_vector(N - 1 downto 0);
        x_in : in std_logic_vector (data_WIDTH - 1 downto 0);
        a_in : in std_logic_vector(data_WIDTH - 1 downto 0);
        b_in : in std_logic_vector(data_WIDTH - 1 downto 0);
        y_out : out std_logic_vector(data_WIDTH - 1 downto 0);
        decimation_factor : in std_logic_vector(data_WIDTH - 1 downto 0)
    );
end MULTISTAGE_IIR_DECIMATOR;

architecture MULTISTAGE of MULTISTAGE_IIR_DECIMATOR is    
    subtype SLV_data_WIDTH is std_logic_vector(data_WIDTH - 1 downto 0);
    type RAM_N is array (0 to N-1) of SLV_data_WIDTH;
    
    -- DEMUX top level signals for each stage 
    signal x_n, a_n, b_n, y_n, d_n : RAM_N := (others => (others => '0')); 
      
  -- Internal Routing Signals
	signal s_xin: std_logic_vector(data_WIDTH - 1 downto 0);	
	signal s_yout : std_logic_vector (data_WIDTH - 1 downto 0);
begin		 
    
    s_xin <= x_in;
    -- Generate IIR Decimators
    GEN_IIR : for i in 0 to N - 1 generate
    IIR_FILTERS : entity IIR_DECIMATOR
      generic map (data_WIDTH => data_WIDTH, L => L)
      port map (
        clk => clk,
        reset => reset,					                
        load_coeff => load_coeff(i),
        x_in => x_n(i),
        a_in => a_n(i),
        b_in => b_n(i),
        y_out => y_n(i),
        decimation_factor => d_n(i)
      );
    end generate;   
     
    -- Process to load coefficients and decimation factor for each stage
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                    x_n <= (others => (others => '0'));
                    a_n <= (others => (others => '0'));
                    b_n <= (others => (others => '0'));
                    y_n <= (others => (others => '0'));
                    d_n <= (others => (others => '0'));                  
            else
                -- First stage gets input directly
                x_n(0) <= s_xin;

                -- Cascade input to the next stages
                for i in 1 to N - 1 loop
                    x_n(i) <= y_n(i-1);     
                end loop;           
            
                for i in 0 to N - 1 loop 
                    -- DEMUX input signals 
                   if load_coeff(i) = '1' then
                        a_n(i) <= a_in;
                        b_n(i) <= b_in;
                        d_n(i) <= decimation_factor;
                    end if;
                    
                    -- DEMUX output signals 
                   if tap(i) = '1' and load_coeff(i) = '0' then
                       y_out <= y_n(i);
                   end if;  
                end loop;         
            end if;
        end if;     
    end process;       
end MULTISTAGE;
