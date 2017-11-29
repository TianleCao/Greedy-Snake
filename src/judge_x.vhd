library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
---------------------------------------------
entity judge_x is
port(
		axis:in std_logic;
		data_x:in std_logic_vector(7 downto 0);
		up_d:out std_logic;
		down_d:out std_logic
--		delta:out std_logic_vector(7 downto 0)
);
end judge_x;
---------------------------------------------
architecture arc of judge_x is
type counter is range 0 to 3;
signal count_up,count_down:counter;
signal temp:integer;
signal up_temp,down_temp:std_logic;
begin
	process(axis)
	begin 
		if rising_edge(axis) then
			if data_x(7)='0' then 
				temp<=conv_integer(data_x);
			else temp<=-conv_integer(not(data_x)+1);	
			end if;
			if temp>30 then up_temp<='1'; down_temp<='0';
			elsif temp<-30 then down_temp<='1'; up_temp<='0';
			else down_temp<='0'; up_temp<='0';
			end if;
			if up_temp='0' then count_up<=0;up_d<='0';
			else
				if count_up=3 then up_d<=up_temp;
				else count_up<=count_up+1;
				end if;
			end if;
			if down_temp='0' then count_down<=0;down_d<='0';
			else 
				if count_down=3 then down_d<=down_temp;
				else count_down<=count_down+1;
				end if;
			end if;
		end if;
	end process;
end arc;