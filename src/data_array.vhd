library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DATA_ARRAY is
	generic(
		ADDRESS_SIZE : integer;
		DATA_SIZE : integer
	);
	port(
		CLK			:	in	std_logic;
		ADDRESS		:	in	std_logic_vector(ADDRESS_SIZE - 1 downto 0);
		WRITE_EN	:	in	std_logic;
		IN_DATA		:	in	std_logic_vector(DATA_SIZE - 1 downto 0);
		OUT_DATA	:	out std_logic_vector(DATA_SIZE - 1 downto 0)
	);
end entity;

architecture DATA_ARRAY_ARCH of DATA_ARRAY is
	type data_type is array ((2 ** ADDRESS_SIZE) - 1 downto 0) of std_logic_vector (DATA_SIZE - 1 downto 0);
	
	signal DATA : data_type;
	
begin
	CLK_PRC : process (CLK, WRITE_EN) is
	begin
		if rising_edge(CLK) then
			if WRITE_EN = '1' then
				DATA(to_integer(unsigned(ADDRESS))) <= IN_DATA;
			end if;
			OUT_DATA <= DATA(to_integer(unsigned(ADDRESS)));
		end if;
	end process CLK_PRC;
	
end architecture DATA_ARRAY_ARCH;