----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/11/2024 08:17:12 PM
-- Design Name: 
-- Module Name: WB - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity WB is
  Port (
       MEMtoReg: in std_logic;
       MEMData: in std_logic_vector(31 downto 0);
       ALURes: in std_logic_vector(31 downto 0);
       WData: out std_logic_vector(31 downto 0)
       );
end WB;

architecture Behavioral of WB is

begin

--mux 2:1
WData <= MEMData when MEMtoReg = '1' else ALURes;

end Behavioral;
