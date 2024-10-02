----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/04/2024 10:40:30 AM
-- Design Name: 
-- Module Name: SSD - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SSD is
    Port ( 
           clock : in STD_LOGIC;
           anod : out STD_LOGIC_VECTOR (7 downto 0);
           catod : out STD_LOGIC_VECTOR (6 downto 0);
           digits: in STD_LOGIC_VECTOR (31 downto 0));
end SSD;

architecture Behavioral of SSD is
signal count: std_logic_vector(16 downto 0) := (others => '0');
signal sel: std_logic_vector (2 downto 0);
signal digit: std_logic_vector (3 downto 0);
begin
process (clock)
begin
    if clock'event and clock = '1' then
    count <= count + 1;
    end if;
end process;
sel <= count(16 downto 14);

mux_cat:
process(sel,digits)
begin
    case sel is
     when "000" => digit <= digits(3 downto 0);
     when "001" => digit <= digits(7 downto 4);
     when "010" => digit <= digits(11 downto 8);
     when "011" => digit <= digits(15 downto 12);
     when "100" => digit <= digits(19 downto 16);
     when "101" => digit <= digits(23 downto 20);
     when "110" => digit <= digits(27 downto 24);
     when "111" => digit <= digits(31 downto 28);
     when others => digit <= "0000";
    end case;
end process;

mux_an:
process(sel)
begin
    case sel is
     when "000" => anod <= "11111110";
     when "001" => anod <= "11111101";
     when "010" => anod <= "11111011";
     when "011" => anod <= "11110111";
     when "100" => anod <= "11101111";
     when "101" => anod <= "11011111";
     when "110" => anod <= "10111111";
     when "111" => anod <= "01111111";
     when others => anod <= "11111110";
    end case;
end process;

with digit select catod <=
    "1111001" when "0001", --1
    "0100100" when "0010", --2
    "0110000" when "0011", --3
    "0011001" when "0100", --4
    "0010010" when "0101", --5
    "0000010" when "0110", --6
    "1111000" when "0111", --7
    "0000000" when "1000", --8
    "0010000" when "1001", --9
    "0001000" when "1010", --A
    "0000011" when "1011", --B
    "1000110" when "1100", --C
    "0100001" when "1101", --D
    "0000110" when "1110", --E
    "0001110" when "1111", --F
    "1000000" when others; --0
end Behavioral;
