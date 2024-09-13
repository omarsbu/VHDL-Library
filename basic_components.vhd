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
  data_out <= data_in(to_integer(unsigned(select_line)));
end architecture;
