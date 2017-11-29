library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
---------------------------------------------
entity decipherer is
	port(data:in std_logic_vector(3 downto 0);
			codon:out std_logic_vector(7 downto 0));
end decipherer;
---------------------------------------------
architecture arc of decipherer is
begin
	process(data)
	begin
		case data is
		when "0000"=>codon<="00000011";
		when "0001"=>codon<="10011111";
		when "0010"=>codon<="00100101";
		when "0011"=>codon<="00001101";
		when "0100"=>codon<="10011001";
		when "0101"=>codon<="01001001";
		when "0110"=>codon<="01000001";
		when "0111"=>codon<="00011111";
		when "1000"=>codon<="00000001";
		when "1001"=>codon<="00001001";
		when "1010"=>codon<="00010001";
		when "1011"=>codon<="11000001";
		when "1100"=>codon<="01100011";
		when "1101"=>codon<="10000101";
		when "1110"=>codon<="01100001";
		when others=>codon<="11111111";
		end case;
	end process;
end arc;