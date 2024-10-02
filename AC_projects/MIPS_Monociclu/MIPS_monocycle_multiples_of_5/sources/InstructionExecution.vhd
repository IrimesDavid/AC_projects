----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/28/2024 02:15:01 PM
-- Design Name: 
-- Module Name: test_env - Behavioral
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
--use IEEE.STD_LOGIC_ARITH.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity InstructionExecution is
    Port ( 
        PCInc: in STD_LOGIC_VECTOR (31 downto 0);
        RD1: in STD_LOGIC_VECTOR (31 downto 0);
        RD2: in STD_LOGIC_VECTOR (31 downto 0);
        ExtImm: in STD_LOGIC_VECTOR (31 downto 0);
        func: in STD_LOGIC_VECTOR (5 downto 0);
        sa: in STD_LOGIC_VECTOR (4 downto 0); 
        ALUSrc: in STD_LOGIC;
        ALUOp: in STD_LOGIC_VECTOR (2 downto 0);
        BranchAddr: out STD_LOGIC_VECTOR (31 downto 0);
        ALURes: out STD_LOGIC_VECTOR (31 downto 0);
        Zero: out STD_LOGIC
          );
end InstructionExecution;

architecture Behavioral of InstructionExecution is

signal ALUCtrl: STD_LOGIC_VECTOR(2 downto 0);
signal ALUIn2: STD_LOGIC_VECTOR(31 downto 0);
signal res: STD_LOGIC_VECTOR(31 downto 0);
signal sa_s: STD_LOGIC_VECTOR(4 downto 0);

begin
--obtinem semnalul sa
sa_s <= sa;

--Input2(B) MUX
ALUIn2 <= RD2 when ALUSrc = '0' else ExtImm;

--ALUCtrl
process(ALUOp, func)
begin  
    case ALUOp is
        when "000" => --R type
            case func is
                when "100000" => ALUCtrl <= "000"; --ADD
                when "100010" => ALUCtrl <= "001"; --SUB
                when "000000" => ALUCtrl <= "010"; --SLL
                when "000010" => ALUCtrl <= "011"; --SRL
                when "100100" => ALUCtrl <= "100"; --AND
                when "100101" => ALUCtrl <= "101"; --OR
                when "100110" => ALUCtrl <= "110"; --XOR
                when "101010" => ALUCtrl <= "111"; --SLT
                when others => ALUCtrl <= (others => 'X'); --unknown
            end case;
        when "001" => ALUCtrl <= "000"; --addi (+)
        when "010" => ALUCtrl <= "100"; --andi (si logic)
        when "011" => ALUCtrl <= "000"; --lw (+)
        when "100" => ALUCtrl <= "000"; --sw (+)
        when "101" => ALUCtrl <= "001"; --beq (-)
        when "110" => ALUCtrl <= "001"; --bne (-)
        when "111" => ALUCtrl <= "111"; --slti (comparatie)
        when others => ALUCtrl <= (others => 'X'); --unknown/ j
    end case;
end process;

--ALU
process(ALUCtrl, RD1, AluIn2, sa)
begin
    case ALUCtrl is
        when "000" => --ADD
            res <= std_logic_vector(signed(RD1) + signed(ALUIn2)); --signed
        when "001" => --SUB
            res <= std_logic_vector(signed(RD1) - signed(ALUIn2)); --signed
        when "010" => --SLL
            res <= std_logic_vector(shift_left(unsigned(RD1), to_integer(unsigned(sa_s))));
        when "011" => --SRL
            res <= std_logic_vector(shift_right(unsigned(RD1), to_integer(unsigned(sa_s))));
        when "100" => --AND
            res <= RD1 and ALUIn2;
        when "101" => --OR
            res <= RD1 or ALUIn2;
        when "110" => --XOR
            res <= RD1 xor ALUIn2;
        when "111" => --SLT
            if RD1 < ALUIn2 then
                res <= X"00000001";
            else
                res <= X"00000000";
            end if;
        when others =>
            res <= (others => 'X');
    end case;
end process;
    
--ZeroDetecter
Zero <= '1' when res = X"00000000" else '0';

-- iesirea pentru adresa de branch
BranchAddr <= std_logic_vector(signed(PCInc) + signed(ExtImm)); --signed

--Retinem rezultatul
ALURes <= res;

end Behavioral;
