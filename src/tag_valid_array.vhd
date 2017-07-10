library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TAG_VALID_ARRAY is
	generic(
		INDEX_SIZE : integer;
		TAG_SIZE : integer
	);
	port(
		CLK			:	in	std_logic;
		RESET_N		:	in	std_logic;
		INDEX		:	in	std_logic_vector(INDEX_SIZE - 1 downto 0);
		WRITE_EN	:	in	std_logic;
		INVALIDATE	:	in	std_logic;
		IN_TAG		:	in	std_logic_vector(TAG_SIZE - 1 downto 0);
		OUT_TAG		:	out std_logic_vector(TAG_SIZE - 1 downto 0);
		IS_VALID	:	out	std_logic
	);
end entity;

architecture TAG_VALID_ARRAY_ARCH of TAG_VALID_ARRAY is
	type tag_type is array ((2 ** INDEX_SIZE) - 1 downto 0) of std_logic_vector (TAG_SIZE - 1 downto 0);
	type valid_type is array ((2 ** INDEX_SIZE) - 1 downto 0) of std_logic;
	
	signal TAGS		: tag_type;
	signal VALIDS	: valid_type;
	
begin
	CLK_PRC : process (CLK, WRITE_EN) is
	begin
		if rising_edge(CLK) then
			if WRITE_EN = '1' then
				TAGS(to_integer(unsigned(INDEX))) <= IN_TAG;
			end if;
			if RESET_N = '1' then
				for I in 0 to 2 ** INDEX_SIZE loop
					VALIDS(I) <= '0';
				end loop;
			end if;
			if INVALIDATE = '1' then
				VALIDS(to_integer(unsigned(INDEX))) <= '0';
			end if;
			
			OUT_TAG		<= TAGS(to_integer(unsigned(INDEX)));
			IS_VALID	<= VALIDS(to_integer(unsigned(INDEX)));
		end if;
	end process CLK_PRC;
	
end architecture TAG_VALID_ARRAY_ARCH;