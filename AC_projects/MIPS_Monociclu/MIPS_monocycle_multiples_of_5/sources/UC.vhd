----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/29/2021 07:28:12 PM
-- Design Name: 
-- Module Name: UC - Behavioral
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

entity UC is
  Port ( 
        Instr : in std_logic_vector(5 downto 0);
        RegDst : out std_logic;
        ExtOp : out std_logic;
        ALUSrc : out std_logic;
        Branch : out std_logic; --branch on equal
        Bne : out std_logic;    --branch on not equal
        Jump : out std_logic;
        ALUOp : out std_logic_vector(2 downto 0);
        MemWrite : out std_logic;
        MemtoReg : out std_logic;
        RegWrite : out std_logic
       );
end UC;

architecture Behavioral of UC is

begin
    process(Instr)
    begin
        RegDst <= '0';
        ExtOp <= '0';
        ALUSrc <= '0';
        Branch <= '0';
        Bne <= '0';
        Jump <= '0';
        MemWrite <= '0';
        MemtoReg <= '0';
        ALUOp <= "000";
        RegWrite <= '0';
        case (Instr) is
            when "000000" => -- tip R
                RegDst <= '1';
                RegWrite <= '1';
                ALUOp <= "000";
            when "001000" => -- addi
                ExtOp <= '1';
                ALUSrc <= '1';
                RegWrite <= '1';
                ALUOp <= "001";
            when "001100" => -- andi
                ALUSrc <= '1';
                RegWrite <= '1';
                ALUOp <= "010";
            when "100011" => -- lw
                RegWrite <= '1';
                ALUSrc <= '1';
                ExtOp <= '1';
                MemtoReg <= '1';
                ALUOp <= "011";
            when "101011" => -- sw
                ALUSrc <= '1';
                ExtOp <= '1';
                MemWrite <= '1';
                ALUOp <= "100";
            when "000100" => -- beq
                ExtOp <= '1';
                Branch <= '1';
                ALUOp <= "101";
            when "000101" => -- bne
                ExtOp <= '1';
                Bne <= '1';
                ALUOp <= "110";
            when "001010" => --slti (nu este nevoie de semnal de control)
                ALUOp <= "111";
            when "000010" => -- j
                Jump <= '1';
            when others =>
                RegDst <= '0';
                ExtOp <= '0';
                ALUSrc <= '0';
                Branch <= '0';
                Bne <= '0';
                Jump <= '0';
                MemWrite <= '0';
                MemtoReg <= '0';
                ALUOp <= "000";
                RegWrite <= '0';
        end case;
    end process;

end Behavioral;
