--------------------------------------------------------------------------------
-- Author:        Parham Alvani (parham.alvani@gmail.com)
--
-- Create Date:   16-03-2017
-- Module Name:   memory.vhd
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity memory is
	generic (blocksize : integer := 1024);

	port (clk, readmem, writemem : in std_logic;
		addressbus: in std_logic_vector (15 downto 0);
		databus : inout std_logic_vector (15 downto 0);
		memdataready : out std_logic := '0');
end entity memory;

architecture behavioral of memory is
	type mem is array (0 to blocksize - 1) of std_logic_vector (15 downto 0);
begin
	process (clk)
		variable buffermem : mem := (others => (others => '0'));
		variable ad : integer;
		variable init : boolean := true;
		
		
		
	begin
--		buffermem(0) := "ZZZZZZZZ00000000";
--		buffermem(0) := "0000001000000011";
		buffermem(0) := "1111000000001000";
		buffermem(1) := "1111000101010000";
		buffermem(2) := "1111010000000000";
		buffermem(3) := "1111010100110100";
		buffermem(4) := "1011010000000000";
		
--		if init = true then
--			-- some initiation
--			buffermem(0) := "0000000000000000";
--			init := false;
--		end if;


--		memdataready <= '0';

		if  clk'event and clk = '1' then
			ad := to_integer(unsigned(addressbus));

			if readmem = '1' then -- Readiing :)
				memdataready <= '1';
				if ad >= blocksize then
					databus <= (others => 'Z');
				else
					databus <= buffermem(ad);
				end if;
			elsif writemem = '1' then -- Writing :)
				memdataready <= '1';
				if ad < blocksize then
					buffermem(ad) := databus;
				end if;
			else
				databus <= (others => 'Z');				
			end if;
		end if;
	end process;
end architecture behavioral;
