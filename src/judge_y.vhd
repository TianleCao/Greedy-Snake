library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
---------------------------------------------
entity judge_y is
port(
		axis:in std_logic;
		data_y:in std_logic_vector(7 downto 0);
		left_d:out std_logic;
		right_d:out std_logic
--		delta:out std_logic_vector(7 downto 0)
);
end judge_y;
---------------------------------------------
architecture arc of judge_y is
type counter is range 0 to 3;
signal count_left,count_right:counter;
signal temp:integer;
signal left_temp,right_temp:std_logic;
begin
	process(axis)
	begin 
		if falling_edge(axis) then
		if data_y(7)='0' then 
			temp<=conv_integer(data_y);
		else temp<=-conv_integer(not(data_y)+1);
		end if;
			if temp<-20 then right_temp<='1'; left_temp<='0';
			elsif temp>20 then left_temp<='1'; right_temp<='0';
			else left_temp<='0'; right_temp<='0';
			end if;
			if right_temp='0' then count_right<=0;right_d<='0';
			else
				if count_right=3 then right_d<=right_temp;
				else count_right<=count_right+1;
				end if;
			end if;
			if left_temp='0' then count_left<=0;left_d<='0';
			else 
				if count_left=3 then left_d<=left_temp;
				else count_left<=count_left+1;
				end if;
			end if;
		end if;
	end process;
end arc;