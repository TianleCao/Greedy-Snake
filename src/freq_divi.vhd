library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
---------------------------------------------
entity freq_divi is
	port(clk_in:in std_logic;
		  clk_out:out std_logic);
end freq_divi;
---------------------------------------------
architecture arc of freq_divi is
	type integer is range 0 to 5;
	signal count:integer;
	signal temp:std_logic;
begin 
	process(clk_in)
	begin
	if (clk_in'event and clk_in='1') then
		if count=5 then
			count<=0; 
			temp<=not temp;
		else count<=count+1;
		end if;
	end if;
	clk_out<=temp;
	end process;
end architecture arc;