library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
---------------------------------------------
entity communication is
	port(CLK:in std_logic;
		  axis:in std_logic;
		  start:in std_logic;
		  CS:in std_logic;
		  MOSI:out std_logic;
		  flag:out std_logic;
		  SCLK:out std_logic);
end communication;
----------------------------------------------
architecture arc of communication is
type integer is range 0 to 7;
type state is (s0,s1,s2,s3);
signal pstate:state;
signal count,set:integer;
begin
	process (CLK)
	variable command,address:std_logic_vector(7 downto 0);
	begin
	SCLK<=CLK;
	if falling_edge(CLK) then 
		if set=1 then 
			if axis='1' then address:="00001000";--x轴
			else address:="00001001";		--y轴
			end if;
			command:="00001011";
		else 
			address:="00101101";
			command:="00001010";
		end if;
		case pstate is 
		when s0=> 
		flag<='0';
		if start='1' then pstate<=s1; count<=7; end if; 
		when s1=>			
			case count is 
			when 7=> MOSI<=command(7); count<=count-1;
			when 6=> MOSI<=command(6); count<=count-1;
			when 5=> MOSI<=command(5); count<=count-1;
			when 4=> MOSI<=command(4); count<=count-1;
			when 3=> MOSI<=command(3); count<=count-1;
			when 2=> MOSI<=command(2); count<=count-1;
			when 1=> MOSI<=command(1); count<=count-1;
			when 0=> MOSI<=command(0); pstate<=s2; count<=7;
			end case;
		when s2=>
			case count is 
			when 7=> MOSI<=address(7); count<=count-1;
			when 6=> MOSI<=address(6); count<=count-1;
			when 5=> MOSI<=address(5); count<=count-1;
			when 4=> MOSI<=address(4); count<=count-1;
			when 3=> MOSI<=address(3); count<=count-1;
			when 2=> MOSI<=address(2); count<=count-1;
			when 1=> MOSI<=address(1); count<=count-1;
			when 0=> MOSI<=address(0); pstate<=s3; count<=7; 
			end case;
		when s3=>
			if set=1 then 
				if count/=0 then count<=count-1; flag<='1';
				else pstate<=s0;
				end if;
			else 
				case count is 
				when 7=> MOSI<='0'; count<=count-1;
				when 6=> MOSI<='0'; count<=count-1;
				when 5=> MOSI<='0'; count<=count-1;
				when 4=> MOSI<='1'; count<=count-1;
				when 3=> MOSI<='0'; count<=count-1;
				when 2=> MOSI<='0'; count<=count-1;
				when 1=> MOSI<='1'; count<=count-1;
				when 0=> MOSI<='0'; pstate<=s0; set<=1;
				end case;
			end if;
		end case;
	end if;
	end process;
end arc;