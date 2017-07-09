library IEEE;
use IEEE.std_logic_1164.all;

entity TB is
end entity;

architecture TB_ARCH of TB is
	component DATA_ARRAY is
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
	end component;
	
	
	signal CLK_COUNTER	: integer := 0;
	signal CLK_COUNT	: integer := 50;
	signal CLK : std_logic := '1';
	
	signal ADDRESS				: std_logic_vector(5 downto 0);
	signal WRITE_EN				: std_logic;
	signal IN_DATA, OUT_DATA	: std_logic_vector(15 downto 0);
	
begin
	DATA_ARRAY_inst : component DATA_ARRAY
		generic map(
			ADDRESS_SIZE => 6,
			DATA_SIZE    => 16
		)
		port map(
			CLK      => CLK,
			ADDRESS  => ADDRESS,
			WRITE_EN => WRITE_EN,
			IN_DATA  => IN_DATA,
			OUT_DATA => OUT_DATA
		);
		
	
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
		WRITE_EN	<= '1';
		ADDRESS		<= "000000";
		IN_DATA		<= "1010101000101000";
		wait for 200 ns;
		
		WRITE_EN	<= '1';
		ADDRESS		<= "000001";
		IN_DATA		<= "1010001000001000";
		
		wait for 300 ns;
		
		ADDRESS		<= "000000";
		
		wait for 400 ns;
		
		ADDRESS		<= "000000";
		
		wait for 400 ns;
		
		assert false report "Reached end of the clock generation";
		wait;
	end process TEST_SIGS;
	
end architecture;