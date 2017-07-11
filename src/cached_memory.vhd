library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CACHED_MEMORY is
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
end entity;

architecture CACHED_MEMORY_ARCH of CACHED_MEMORY is
	component memory is
		generic (blocksize : integer := 1024);
	
		port (clk, readmem, writemem : in std_logic;
			addressbus: in std_logic_vector (15 downto 0);
			databus : inout std_logic_vector (15 downto 0);
			memdataready : out std_logic := '0');
	end component memory;
	
	component DATA_PATH is
		generic(
			ADDRESS_SIZE : integer;
			DATA_SIZE : integer
		);
		port(
			CLK				:  in 	std_logic;
			ADDRESS			:  in	std_logic_vector(ADDRESS_SIZE - 1 downto 0);
			DATA_IN			:  in 	std_logic_vector(DATA_SIZE - 1 downto 0);
			DATA_OUT		:  out	std_logic_vector(DATA_SIZE - 1 downto 0);
			W_EN			:  in 	std_logic;
			R_EN			:  in	std_logic;
			MEMORY_OUT		:  in	std_logic_vector(DATA_SIZE - 1 downto 0);
			MEMORY_IN		:  out	std_logic_vector(DATA_SIZE - 1 downto 0);
			MEMORY_ADDRESS	:  out	std_logic_vector(ADDRESS_SIZE - 1 downto 0);
			W_EN_MEM		:  out	std_logic;
			R_EN_MEM		:  out	std_logic;
			MEM_DATA_READY	:  out  std_logic
		);
	end component;
	
	signal READ_MEM_MEMORY	: std_logic;
	signal WRITE_MEM_MEMORY	: std_logic;
	signal MEMORY_ADDRESS	: std_logic_vector(ADDRESS_SIZE - 1 downto 0);
	signal MEMORY_DATA		: std_logic_vector(DATA_SIZE - 1 downto 0);
	signal MEMORY_MEM_DATA_READY : std_logic;
	
begin
	DATA_PATH_inst : component DATA_PATH
		generic map(
			ADDRESS_SIZE => ADDRESS_SIZE,
			DATA_SIZE    => DATA_SIZE
		)
		port map(
			CLK            => CLK,
			ADDRESS        => ADRESS_BUS,
			DATA_IN        => DATA_BUS,
			DATA_OUT       => DATA_BUS,
			W_EN           => WRITEMEM,
			R_EN           => READMEM,
			MEMORY_OUT     => MEMORY_DATA,
			MEMORY_IN      => MEMORY_DATA,
			MEMORY_ADDRESS => MEMORY_ADDRESS,
			W_EN_MEM       => WRITE_MEM_MEMORY,
			R_EN_MEM       => READ_MEM_MEMORY,
			MEM_DATA_READY => MEM_DATA_READY
		);
		
	memory_inst : component memory
		port map(
			clk          => clk,
			readmem      => READ_MEM_MEMORY,
			writemem     => WRITE_MEM_MEMORY,
			addressbus   => MEMORY_ADDRESS,
			databus      => MEMORY_DATA,
			memdataready => MEMORY_MEM_DATA_READY
		);
end architecture CACHED_MEMORY_ARCH;