library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DATA_PATH is
	generic(
		ADDRESS_SIZE : integer;
		DATA_SIZE : integer
	);
	port(
		CLK				:  in 	std_logic;
		ADDRESS			:  in	std_logic_vector(ADDRESS_SIZE - 1 downto 0);
		DATA_IN			:  in 	std_logic_vector((2 ** ADDRESS_SIZE) - 1 downto 0);
		DATA_OUT		:  out	std_logic_vector((2 ** ADDRESS_SIZE) - 1 downto 0);
		W_EN			:  in 	std_logic;
		R_EN			:  in	std_logic;
		MEMORY_OUT		:  in	std_logic_vector((2 ** ADDRESS_SIZE) - 1 downto 0);
		MEMORY_IN		:  out	std_logic_vector((2 ** ADDRESS_SIZE) - 1 downto 0);
		MEMORY_ADDRESS	:  out	std_logic_vector(ADDRESS_SIZE - 1 downto 0);
		W_EN_MEM		:  out	std_logic;
		R_EN_MEM		:  out	std_logic;
		MEM_DATA_READY	:  out  std_logic
	);
end entity;

architecture DATA_PATH_ARCH of DATA_PATH is
	component DATA_ARRAY is
		generic(
			INDEX_SIZE : integer;
			DATA_SIZE : integer
		);
		port(
			CLK			:	in	std_logic;
			INDEX		:	in	std_logic_vector(INDEX_SIZE - 1 downto 0);
			WRITE_EN	:	in	std_logic;
			IN_DATA		:	in	std_logic_vector(DATA_SIZE - 1 downto 0);
			OUT_DATA	:	out std_logic_vector(DATA_SIZE - 1 downto 0)
		);
	end component;
	
	component TAG_VALID_ARRAY is
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
			IN_VALID	:	in	std_logic;
			IN_TAG		:	in	std_logic_vector(TAG_SIZE - 1 downto 0);
			OUT_TAG		:	out std_logic_vector(TAG_SIZE - 1 downto 0);
			IS_VALID	:	out	std_logic
		);
	end component;
	
	component HIT_MISS_LOGIC is
		generic(
			INDEX_SIZE : integer;
			TAG_SIZE : integer
		);
		port(
			TAG			: in  std_logic_vector(TAG_SIZE - 1 downto 0);
			W0_TAG		: in  std_logic_vector(TAG_SIZE - 1 downto 0);
			W0_VALID	: in  std_logic;
			W1_TAG		: in  std_logic_vector(TAG_SIZE - 1 downto 0);
			W1_VALID	: in  std_logic;
			HIT			: out std_logic;
			W0_IS_VALID	: out std_logic;
			W1_IS_VALID	: out std_logic
		);
	end component;
	
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
	
	
	component CONTROLLER is
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
			MODULE_R_EN		: in   std_logic
		);
	end component;
		
	
	constant INDEX_SIZE		: integer := 6;
	constant TAG_SIZE		: integer := 4;
	constant COUNTER_SIZE	: integer := 16;
	
	signal ADDRESS_IN_TAG	: std_logic_vector(TAG_SIZE - 1 downto 0);
	signal ADDRESS_IN_INDEX	: std_logic_vector(INDEX_SIZE - 1 downto 0);
	
	signal DA0_W_EN			: std_logic;		--- Write Enable signal for Data Array 0
	signal DA1_W_EN			: std_logic;		--- Write Enable signal for Data Array 1
	
	signal DA0_DATA_OUT		: std_logic_vector(DATA_SIZE - 1 downto 0);
	signal DA1_DATA_OUT		: std_logic_vector(DATA_SIZE - 1 downto 0);
	
	signal TAG0				: std_logic_vector(TAG_SIZE - 1 downto 0);
	signal TAG1				: std_logic_vector(TAG_SIZE - 1 downto 0);
	signal VALID0			: std_logic;
	signal VALID1			: std_logic;
	
	signal INVALIDATE0		: std_logic;
	signal INVALIDATE1		: std_logic;
	
	signal DA0_ON_DATABUS	: std_logic;
	signal DA1_ON_DATABUS	: std_logic;
	
	signal RESET_N0			: std_logic;
	signal RESET_N1			: std_logic;
	signal TVA0_W_EN		: std_logic;
	signal TVA1_W_EN		: std_logic;
	signal IS_HIT			: std_logic;
	signal W0_IS_VALID		: std_logic;
	signal W1_IS_VALID		: std_logic;
	
	signal COUNTER_IN0		: std_logic_vector(COUNTER_SIZE - 1 downto 0);
	signal COUNTER_IN1		: std_logic_vector(COUNTER_SIZE - 1 downto 0);
	signal COUNTER_PLUS0	: std_logic;
	signal COUNTER_PLUS1	: std_logic;
	signal COUNTER_RESET_0	: std_logic;
	signal COUNTER_RESET_1	: std_logic;
	
	signal IN_VALIDATE_DVA0	: std_logic;
	signal IN_VALIDATE_DVA1	: std_logic;
	
	signal DATA_BUS		: std_logic_vector(DATA_SIZE - 1 downto 0);
	
	-----------------
	--- TAG|INDEX ---
	-----------------
begin
	MEMORY_ADDRESS <= ADDRESS;
	
	DATA_ARRAY_0 : component DATA_ARRAY
		generic map(
			INDEX_SIZE => INDEX_SIZE,
			DATA_SIZE  => DATA_SIZE
		)
		port map(
			CLK      => CLK,
			INDEX    => ADDRESS_IN_INDEX,
			WRITE_EN => DA0_W_EN,
			IN_DATA  => DATA_BUS,
			OUT_DATA => DA0_DATA_OUT
		);
		
	DATA_ARRAY_1 : component DATA_ARRAY
		generic map(
			INDEX_SIZE => INDEX_SIZE,
			DATA_SIZE  => DATA_SIZE
		)
		port map(
			CLK      => CLK,
			INDEX    => ADDRESS_IN_INDEX,
			WRITE_EN => DA1_W_EN,
			IN_DATA  => DATA_BUS,
			OUT_DATA => DA1_DATA_OUT
		);
		
	TAG_VALID_ARRAY_0 : component TAG_VALID_ARRAY
		generic map(
			INDEX_SIZE => INDEX_SIZE,
			TAG_SIZE   => TAG_SIZE
		)
		port map(
			CLK        => CLK,
			RESET_N    => RESET_N0,
			INDEX      => ADDRESS_IN_INDEX,
			WRITE_EN   => TVA0_W_EN,
			INVALIDATE => INVALIDATE0,
			IN_VALID   => IN_VALIDATE_DVA0,
			IN_TAG     => ADDRESS_IN_TAG,
			OUT_TAG    => TAG0,
			IS_VALID   => VALID0
		);
		
	TAG_VALID_ARRAY_1 : component TAG_VALID_ARRAY
		generic map(
			INDEX_SIZE => INDEX_SIZE,
			TAG_SIZE   => TAG_SIZE
		)
		port map(
			CLK        => CLK,
			RESET_N    => RESET_N1,
			INDEX      => ADDRESS_IN_INDEX,
			WRITE_EN   => TVA1_W_EN,
			INVALIDATE => INVALIDATE1,
			IN_VALID   => IN_VALIDATE_DVA1,
			IN_TAG     => ADDRESS_IN_TAG,
			OUT_TAG    => TAG1,
			IS_VALID   => VALID1
		);
		
	HIT_MISS_LOGIC_inst : component HIT_MISS_LOGIC
		generic map(
			INDEX_SIZE => INDEX_SIZE,
			TAG_SIZE   => TAG_SIZE
		)
		port map(
			TAG         => ADDRESS_IN_TAG,
			W0_TAG      => TAG0,
			W0_VALID    => VALID0,
			W1_TAG      => TAG1,
			W1_VALID    => VALID1,
			HIT         => IS_HIT,
			W0_IS_VALID => W0_IS_VALID,
			W1_IS_VALID => W1_IS_VALID
		);
		
	COUNTER_ARRAY_inst : component COUNTER_ARRAY
		generic map(
			INDEX_SIZE   => INDEX_SIZE,
			COUNTER_SIZE => 12
		)
		port map(
			CLK         => CLK,
			INDEX       => ADDRESS_IN_INDEX,
			PLUS_ONE_0  => COUNTER_PLUS0,
			PLUS_ONE_1  => COUNTER_PLUS1,
			RESET_O     => COUNTER_RESET_0,
			RESET_1     => COUNTER_RESET_1,
			COUNT_OUT_0 => COUNTER_IN0,
			COUNT_OUT_1 => COUNTER_IN1
		);
		
	CONTROLLER_inst : component CONTROLLER
		port map(
			CLK         	=> CLK,
			RESET_N0    	=> RESET_N0,
			RESET_N1    	=> RESET_N1,
			DA0_W_EN    	=> DA0_W_EN,
			DA1_W_EN    	=> DA1_W_EN,
			DA0_ON_DATABUS	=> DA0_ON_DATABUS,
			DA1_ON_DATABUS	=> DA1_ON_DATABUS,
			TVA0_W_EN   	=> TVA0_W_EN,
			TVA1_W_EN   	=> TVA1_W_EN,
			IS_HIT      	=> IS_HIT,
			W0_IS_VALID		=> W0_IS_VALID,
			W1_IS_VALID		=> W1_IS_VALID,
			W0_VALID_IN		=> IN_VALIDATE_DVA0,
			W1_VALID_IN		=> IN_VALIDATE_DVA1,
			COUNTER_IN0		=> COUNTER_IN0,
			COUNTER_IN1		=> COUNTER_IN1,
			COUNTER_PLUS0	=> COUNTER_PLUS0,
			COUNTER_PLUS1	=> COUNTER_PLUS1,
			COUNTER_RESET_0	=> COUNTER_RESET_0,
			COUNTER_RESET_1	=> COUNTER_RESET_1,
			MEM_DATA_READY	=> MEM_DATA_READY,
			MODULE_W_EN		=> W_EN,
			MODULE_R_EN		=> R_EN
		);
		
	ADDRESS_IN_TAG		<= ADDRESS(ADDRESS_SIZE - 1 downto ADDRESS_SIZE - TAG_SIZE);
	ADDRESS_IN_INDEX	<= ADDRESS(ADDRESS_SIZE - TAG_SIZE - 1 downto 0);
	
	DA0_ON_DATABUS_ASSIGNMENT : with DA0_ON_DATABUS select
		DATA_BUS <=
			DA0_DATA_OUT when '1',
			(others => 'Z') when others;
			
	DA1_ON_DATABUS_ASSIGNMENT : with DA1_ON_DATABUS select
		DATA_BUS <=
			DA1_DATA_OUT when '1',
			(others => 'Z') when others;
	
end architecture DATA_PATH_ARCH;