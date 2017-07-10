library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity COUNTER_ARRAY is
	generic(
		INDEX_SIZE		: integer;
		COUNTER_SIZE	: integer
	);
	port(
		CLK			: in  std_logic;
		INDEX		: in  std_logic_vector(INDEX_SIZE - 1 downto 0);
		PLUS_ONE_0	: in  std_logic;
		PLUS_ONE_1	: in  std_logic;
		RESET_O		: in  std_logic;
		RESET_1		: in  std_logic;
		COUNT_OUT_0	: out std_logic_vector(COUNTER_SIZE - 1 downto 0);
		COUNT_OUT_1	: out std_logic_vector(COUNTER_SIZE - 1 downto 0)
	);
end entity;

architecture COUNTER_ARRAY_ARCH of COUNTER_ARRAY is
	type counter_arr is array ((2 ** INDEX_SIZE) - 1 downto 0) of std_logic_vector (COUNTER_SIZE - 1 downto 0);
	signal COUNTER_0	: counter_arr := (others => (others => '0'));
	signal COUNTER_1	: counter_arr := (others => (others => '0'));
begin
	COUNT : process (CLK, RESET_O, RESET_1, PLUS_ONE_0, PLUS_ONE_1) is
	begin
		if rising_edge(CLK) then
			if RESET_O = '1' then
				COUNTER_0(to_integer(unsigned(INDEX))) <= (others => '0');
			end if;
			if RESET_1 = '1' then
				COUNTER_1(to_integer(unsigned(INDEX))) <= (others => '0');
			end if;
			if PLUS_ONE_0 = '1' then
				COUNTER_0(to_integer(unsigned(INDEX))) <= std_logic_vector(unsigned(COUNTER_0(to_integer(unsigned(INDEX)))) + 1);
			end if;
			if PLUS_ONE_1 = '1' then
				COUNTER_1(to_integer(unsigned(INDEX))) <= std_logic_vector(unsigned(COUNTER_1(to_integer(unsigned(INDEX)))) + 1);
			end if;
		end if;
	end process COUNT;
	
	COUNT_OUT_0 <= COUNTER_0(to_integer(unsigned(INDEX)));
	COUNT_OUT_1 <= COUNTER_1(to_integer(unsigned(INDEX)));
end architecture COUNTER_ARRAY_ARCH;