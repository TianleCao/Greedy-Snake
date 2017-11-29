library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
---------------------------------------------
entity mux4_1 is
	port( M0,M1:in bit;
			D0,D1,D2,D3: in std_logic_vector(3 downto 0);
			D: out std_logic_vector(3 downto 0));
end mux4_1;
---------------------------------------------
architecture arc of mux4_1 is
	signal temp:std_logic_vector(3 downto 0);
begin
	process(M1,M0)
	begin 
		case M1 is
		when '0' =>
			case M0 is
			when '0'=> temp<=D0;
			when '1'=> temp<=D1;
			end case;
		when '1' =>
			case M0 is
			when '0'=> temp<=D2;
			when '1'=> temp<=D3;
			end case;
		end case;
	D<=temp;
	end process;
end arc;
		