----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/05/2021 07:47:43 PM
-- Design Name: 
-- Module Name: MEM - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MEM is
  Port ( 
        clk :       in STD_LOGIC;
        MemWrite :  in STD_LOGIC;
        Addr :      in STD_LOGIC_VECTOR (31 downto 0);
        Wdata :    in STD_LOGIC_VECTOR (31 downto 0);
        MEMdata :    out STD_LOGIC_VECTOR (31 downto 0);
        ALURes : out STD_LOGIC_VECTOR (31 downto 0)
       );
end MEM;

architecture Behavioral of MEM is
type ramArray is array (0 to 31) of std_logic_vector(31 downto 0);
signal RAM: ramArray := 
(
    X"00000000", --$zero
    X"00000007", --size
    X"00000005",
    X"00000002",
    X"0000000A",
    X"0000000A",
    X"00000014",
    X"0000000E",
    X"00000014",
    others => X"00000000"
);
begin
--ALURes_out
ALUres <= Addr;

-- citirea asincrona
MEMdata <= RAM(conv_integer(Addr(4 downto 0)));

process (clk) 
begin
    if rising_edge(clk) and MemWrite = '1' then -- scrierea sincrona
        RAM(conv_integer(Addr(7 downto 0))) <= Wdata;
    end if;
end process;

end Behavioral;
