library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
---------------------------------------------
entity sweep_address is
	port(clk:in std_logic;
			M0,M1:out bit;
			enlighten:out std_logic_vector(3 downto 0));
end sweep_address;
---------------------------------------------
architecture arc of sweep_address is
	type state is(s0,s1,s2,s3);
	signal pstate,nstate:state;
begin
	process (clk)
	begin
		if(clk'event and clk='1') then
		pstate<=nstate;
		end if;
	end process;
----------------------------------------------
	process (clk,pstate)
	begin
		case pstate is
		when s0=>nstate<=s1;M1<='0';M0<='0';enlighten<="0001";
		when s1=>nstate<=s2;M1<='0';M0<='1';enlighten<="0010";
		when s2=>nstate<=s3;M1<='1';M0<='0';enlighten<="0100";
		when s3=>nstate<=s0;M1<='1';M0<='1';enlighten<="1000";
		end case;
	end process;
end arc;