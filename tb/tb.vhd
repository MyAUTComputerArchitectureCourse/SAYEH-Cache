library IEEE;
use IEEE.std_logic_1164.all;

entity TB is
end entity;

architecture TB_ARCH of TB is
	component CACHED_MEMORY is
		generic(
			ADDRESS_SIZE	: integer;
			DATA_SIZE		: integer
		);
		port(
			CLK				: in  	std_logic;
			READMEM			: in	std_logic;
			WRITEMEM		: in	std_logic;
			ADRESS_BUS		: in	std_logic_vector(ADDRESS_SIZE - 1 downto 0);
			DATA_BUS		: inout	std_logic_vector(DATA_SIZE - 1 downto 0);
			MEM_DATA_READY	: out	std_logic
		);
	end component;
		
	signal CLK_COUNTER	: integer := 0;
	signal CLK_COUNT	: integer := 50;
	signal CLK : std_logic := '1';
	
	signal ADDRESS_SIZE	: integer := 10;
	signal DATA_SIZE	: integer := 16;
	signal READMEM		: std_logic;
	signal WRITEMEM		: std_logic;
	signal ADDRESS		: std_logic_vector(ADDRESS_SIZE - 1 downto 0);
	signal DATA_BUS		: std_logic_vector(DATA_SIZE - 1 downto 0);
begin
		
	CLOCK_GEN : process is
	begin
		loop
			CLK <= not CLK;
			wait for 100 ns;
			CLK <= not CLK;
			wait for 100 ns;
			
			CLK_COUNTER <= CLK_COUNTER + 1;
			
			if(CLK_COUNTER = CLK_COUNT) then
				assert false report "Reached end of the clock generation";
				wait;
			end if;
			
		end loop;
		
	end process CLOCK_GEN;
	
	TEST_SIGS : process is
	begin
		ADDRESS <= "0000000000";
		READMEM <= '1';
		wait for 400 ns;
		assert false report "Reached end of the clock generation";
		wait;
	end process TEST_SIGS;
	
end architecture;