library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CONTROLLER is
	generic(
		COUNTER_SIZE : integer
	);
	
	port(
		CLK				: in   std_logic;
		RESET_N0		: out  std_logic;
		RESET_N1		: out  std_logic;
		DA0_W_EN		: out  std_logic;
		DA1_W_EN		: out  std_logic;
		DA0_ON_DATABUS	: out  std_logic;
		DA1_ON_DATABUS	: out  std_logic;
		TVA0_W_EN		: out  std_logic;
		TVA1_W_EN		: out  std_logic;
		IS_HIT			: in   std_logic;
		W0_IS_VALID		: in   std_logic;
		W1_IS_VALID		: in   std_logic;
		W0_VALID_IN		: out  std_logic;
		W1_VALID_IN		: out  std_logic;
		COUNTER_IN0		: in   std_logic_vector(COUNTER_SIZE - 1 downto 0);
		COUNTER_IN1		: in   std_logic_vector(COUNTER_SIZE - 1 downto 0);
		COUNTER_PLUS0	: out  std_logic;
		COUNTER_PLUS1	: out  std_logic;
		COUNTER_RESET_0	: out  std_logic;
		COUNTER_RESET_1	: out  std_logic;
		MEM_DATA_READY	: out  std_logic;
		MODULE_W_EN		: in   std_logic;
		MODULE_R_EN		: in   std_logic;
		W_EN_MEM		: out  std_logic;
		R_EN_MEM		: out  std_logic
	);
end entity;

architecture CONTROLLER_ARCH of CONTROLLER is
	type state is (START, HIT_READ, NHIT_READ, HIT_WRITE, NHIT_WRITE);
	signal CURRENT_STATE : state := START;
	
begin
	
	
	COUNT : process (CLK) is
	begin
		if rising_edge(CLK) then
			case CURRENT_STATE is
			when START => 
				RESET_N0		<= '0';
				RESET_N1		<= '0';
				DA0_W_EN		<= '0';
				DA1_W_EN		<= '0';
				TVA0_W_EN		<= '0';
				TVA1_W_EN		<= '0';
				COUNTER_PLUS0	<= '0';
				COUNTER_PLUS1	<= '0';
				COUNTER_RESET_0 <= '0';
				COUNTER_RESET_1 <= '0';
				DA0_ON_DATABUS	<= '0';
				DA1_ON_DATABUS	<= '0';
				MEM_DATA_READY	<= '0';
				W_EN_MEM		<= '0';
				R_EN_MEM		<= '0';
				W0_VALID_IN		<= '0';
				W1_VALID_IN		<= '0';
				if (MODULE_R_EN = '1' and IS_HIT = '1') then
					if (W0_IS_VALID = '1') then
						COUNTER_PLUS0 <= '1';
						DA0_ON_DATABUS <= '1';
						MEM_DATA_READY <= '1';
					end if;
					if (W1_IS_VALID = '1') then
						COUNTER_PLUS1 <= '1';
						DA1_ON_DATABUS <= '1';
						MEM_DATA_READY <= '1';
					end if;
					CURRENT_STATE <= HIT_READ;
				end if;
				if (MODULE_R_EN = '1' and IS_HIT = '0') then
					R_EN_MEM <= '1';
					if (to_integer(unsigned(COUNTER_IN0)) < to_integer(unsigned(COUNTER_IN1))) then
						COUNTER_RESET_0 <= '1';
						TVA0_W_EN		<= '1';
						W0_VALID_IN		<= '1';
						DA0_W_EN		<= '1';
					else	-- to_integer(unsigned(COUNTER_IN0)) <= to_integer(unsigned(COUNTER_IN1))
						COUNTER_RESET_1 <= '1';
						TVA1_W_EN		<= '1';
						W1_VALID_IN		<= '1';
						DA1_W_EN		<= '1';
					end if;
					CURRENT_STATE <= NHIT_READ;
				end if;
				if (MODULE_W_EN = '1' and IS_HIT = '1') then
					if (W0_IS_VALID = '1') then
						COUNTER_RESET_0 <= '1';
						TVA0_W_EN		<= '1';
						W0_VALID_IN		<= '1';
					end if;
					if (W1_IS_VALID = '1') then
						COUNTER_RESET_1 <= '1';
						TVA1_W_EN		<= '1';
						W1_VALID_IN		<= '1';
					end if;
					CURRENT_STATE <= HIT_WRITE;
				end if;
				if (MODULE_W_EN = '1' and IS_HIT = '0') then
					W_EN_MEM <= '1';
					CURRENT_STATE <= NHIT_WRITE;
				end if;
			when HIT_READ =>
				MEM_DATA_READY <= '1';
				CURRENT_STATE <= START;
			when NHIT_READ =>
				MEM_DATA_READY <= '1';
				CURRENT_STATE <= START;
			when HIT_WRITE =>
				CURRENT_STATE <= START;
			when NHIT_WRITE =>
				CURRENT_STATE <= START;
			when others => null;
			end case;
			
		end if;
	end process COUNT;
	
	
end architecture CONTROLLER_ARCH;