library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
---------------------------------------------
entity data_convert is
port(
		data_x:in std_logic_vector(7 downto 0);
		data_y:in std_logic_vector(7 downto 0);
		D3:out std_logic_vector(3 downto 0);
		D2:out std_logic_vector(3 downto 0);
		D1:out std_logic_vector(3 downto 0);
		D0:out std_logic_vector(3 downto 0));
end data_convert;
----------------------------------------------
architecture arc of data_convert is
begin 
	process(data_x,data_y)
	variable data1,data2:integer;
	variable int_D3,int_D2,int_D1,int_D0:integer;
	begin
		data1:=conv_integer(data_x)/4;
		data2:=conv_integer(data_y)/4;
		int_D3:=data1/10;
		int_D2:=data1-int_D3*10;
		int_D1:=data2/10;
		int_D0:=data2-int_D1*10;
		D3<=conv_std_logic_vector(int_D3,4);
		D2<=conv_std_logic_vector(int_D2,4);
		D1<=conv_std_logic_vector(int_D1,4);
		D0<=conv_std_logic_vector(int_D0,4);
	end process;
end arc;