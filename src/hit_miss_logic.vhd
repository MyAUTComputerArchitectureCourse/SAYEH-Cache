library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity HIT_MISS_LOGIC is
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
end entity;

architecture HIT_MISS_LOGIC_ARCH of HIT_MISS_LOGIC is
	
begin
	SIG_GEN : process (TAG, W0_TAG, W0_VALID, W1_TAG, W1_VALID) is
	begin
		if W0_IS_VALID = '0' and W1_IS_VALID = '0' then
			HIT <= '0';
			W0_IS_VALID <= '0';
			W1_IS_VALID <= '0';
		else
			if 	W0_IS_VALID = '1' then
				if W0_TAG = TAG then
					HIT <= '1';
					W0_IS_VALID <= '1';
					W1_IS_VALID <= '0';
				else
					HIT <= '0';
					W0_IS_VALID <= '0';
					W1_IS_VALID <= '0';
				end if;
			end if;
			
			if 	W1_IS_VALID = '1' then
				if W1_TAG = TAG then
					HIT <= '1';
					W0_IS_VALID <= '0';
					W1_IS_VALID <= '1';
				else
					HIT <= '0';
					W0_IS_VALID <= '0';
					W1_IS_VALID <= '0';
				end if;
			end if;
		end if;
	end process SIG_GEN;
	
end architecture DATA_ARRAY_ARCH;