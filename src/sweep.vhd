library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith;
---------------------------------------------
entity sweep is 
port(
	clk:in std_logic;
	axis:out std_logic;
	start:out std_logic;
	CS:out std_logic);
end sweep;
---------------------------------------------
architecture arc of sweep is
type integer is range 0 to 10000;
type counter is range 0 to 2;
signal count:integer;
signal temp:std_logic;
begin 
	process(clk)
	begin
	if falling_edge(clk) then 
		if count=10000 then
			count<=0; 
			temp<=not temp;
			start<='1';
		else count<=count+1; start<='0';
		if count=1 then CS<='0'; end if;
		if count=25 then CS<='1'; end if;
		end if;
	end if;
	axis<=temp;
	end process;
end architecture arc;	
	