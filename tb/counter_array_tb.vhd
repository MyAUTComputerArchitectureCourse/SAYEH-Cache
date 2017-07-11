library IEEE;
use IEEE.std_logic_1164.all;

entity TB is
end entity;

architecture TB_ARCH of TB is
	component COUNTER_ARRAY is
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
	end component;
	
	signal CLK_COUNTER	: integer := 0;
	signal CLK_COUNT	: integer := 50;
	signal CLK : std_logic := '1';
	
	signal INDEX	: std_logic_vector(3 downto 0);
	signal PLUS0	: std_logic;
	signal PLUS1	: std_logic;
	
	signal RESET0	: std_logic;
	signal RESET1	: std_logic;
	
	signal OUT0		: std_logic_vector(5 downto 0);
	signal OUT1		: std_logic_vector(5 downto 0);
	
begin
	COUNTER_ARRAY_inst : component COUNTER_ARRAY
		generic map(
			INDEX_SIZE   => 4,
			COUNTER_SIZE => 6
		)
		port map(
			CLK         => CLK,
			INDEX       => INDEX,
			PLUS_ONE_0  => PLUS0,
			PLUS_ONE_1  => PLUS1,
			RESET_O     => RESET0,
			RESET_1     => RESET1,
			COUNT_OUT_0 => OUT0,
			COUNT_OUT_1 => OUT1
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
		PLUS1  <= '1';
		RESET0 <= '0';
		RESET1 <= '0';
		
		INDEX <= "0000";
		PLUS0 <= '1';
		wait for 200 ns;
		
		INDEX <= "0001";
		PLUS0 <= '1';
		wait for 150 ns;
		
		PLUS0 <= '0';
		INDEX <= "0010";
		PLUS1 <= '1';
		
		wait for 200 ns;
		
		PLUS1 <= '0';
		INDEX <= "0000";
		
		wait for 400 ns;
		
		assert false report "Reached end of the clock generation";
		wait;
	end process TEST_SIGS;
	
end architecture;