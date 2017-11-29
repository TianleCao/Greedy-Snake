library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
---------------------------------------------
entity direction is
port(
		axis:in std_logic;
		up_d:in std_logic;
		down_d:in std_logic;
--		delta_x:in std_logic_vector(7 downto 0);
		left_d:in std_logic;
		right_d:in std_logic;
--		delta_y:in std_logic_vector(7 downto 0);
		led:out std_logic_vector(3 downto 0));
end direction;
---------------------------------------------
architecture arc of direction is
type integer is range 0 to 4;
signal count:integer;
begin 
	process(axis)
	begin 
	if rising_edge(axis) then
		if count=4 then
		if up_d='1' and down_d='0' and left_d='0' and right_d='0' then led<="1000";
		elsif up_d='0' and down_d='1' and left_d='0' and right_d='0' then led<="0100";
		elsif up_d='0' and down_d='0' and left_d='1' and right_d='0' then led<="0010";
		elsif up_d='0' and down_d='0' and left_d='0' and right_d='1' then led<="0001";
--		elsif conv_integer(delta_x)>2*conv_integer(delta_y) then led<=up_d&down_d&"00";
--		elsif conv_integer(delta_y)>2*conv_integer(delta_x) then led<="00"&left_d&right_d;
			else led<="0000";
		end if;
		count<=0;
		else count<=count+1;
		end if;
	end if;
	end process;
end arc;
	