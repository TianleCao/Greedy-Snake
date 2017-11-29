library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
---------------------------------------------
entity data_acquire is
port(
		flag:in std_logic;
		axis:in std_logic;
		SCLK:in std_logic;
		MISO:in std_logic;
		data_x:out std_logic_vector(7 downto 0);
		data_y:out std_logic_vector(7 downto 0));
end data_acquire;
---------------------------------------------
architecture arc of data_acquire is
type integer is range 0 to 7;
signal count:integer;
begin
	process(SCLK)
	variable data:std_logic_vector(7 downto 0);
	begin
	if rising_edge(SCLK) and flag='1' then
		case count is
			when 0=> data(7):=MISO; count<=count+1; 
			when 1=> data(6):=MISO; count<=count+1; 
			when 2=> data(5):=MISO; count<=count+1; 
			when 3=> data(4):=MISO; count<=count+1; 
			when 4=> data(3):=MISO; count<=count+1; 
			when 5=> data(2):=MISO; count<=count+1; 
			when 6=> data(1):=MISO; count<=count+1;
			when 7=> 
				data(0):=MISO; count<=0;
				if axis='1' then data_x<=data;--x轴
				else data_y<=data;
				end if;
		end case;
	end if;
	end process;
end architecture;
	