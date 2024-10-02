----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/22/2021 06:39:47 PM
-- Design Name: 
-- Module Name: instruction_fetch - Behavioral
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

entity InstructionFetch is
  Port ( 
         clk : in STD_LOGIC;
         en : in STD_LOGIC;
         reset : in STD_LOGIC;
         branch_addr : in STD_LOGIC_VECTOR (31 downto 0);
         jmp_addr : in STD_LOGIC_VECTOR (31 downto 0);
         jump : in STD_LOGIC;
         PCSrc : in STD_LOGIC;
         current_instr : out STD_LOGIC_VECTOR (31 downto 0);
         PCInc : out STD_LOGIC_VECTOR (31 downto 0)
        );
end InstructionFetch;

architecture Behavioral of InstructionFetch is

signal pc_out : STD_LOGIC_VECTOR (31 DOWNTO 0) := X"00000000";
signal sum_out : STD_LOGIC_VECTOR (31 downto 0) := X"00000000";
signal mux1_out : STD_LOGIC_VECTOR (31 downto 0) := X"00000000";
signal mux2_out : STD_LOGIC_VECTOR (31 downto 0) := X"00000000";
type rom_array is array (0 to 255) of std_logic_vector(31 downto 0);
signal rom: rom_array := (
    B"100011_00000_10000_0000000000000001",--8C100001 --lw $a0, size(&zero) #size
    B"100011_00000_10001_0000000000000000",--8C110000 --lw $a1, 0($zero) #indice
    B"100011_00000_10011_0000000000000000",--8C130000 --lw $a3, 0($zero) # max = $a3 = 0 initial
    B"100011_00000_10100_0000000000000000",--8C140000 --lw $a4, 0($zero) # RES = cnt_max = $a4
    B"000100_10001_10000_0000000000011000",--12300018 --beq $a1, $a0, end #terminarea buclei
    B"100011_10001_10010_0000000000000010",--8E320002 --lw $a2, arr($a1) # element curent
    B"001000_10001_10001_0000000000000001",--22310001 --addi $a1,$a1,1
    B"000010_00000000000000000000010010",  --20000012 --j isMultipleof5
    B"000100_00001_00000_1111111111111011",--1020FFFB --beq $v0, $zero, continue
    B"000000_10011_10010_11001_00000_101010",--0272C82A --slt $s1, $a3, $a2
    B"000101_11001_00000_0000000000000100",--17200004 --bne $s1, $zero, new_max
    B"000100_10010_10011_0000000000000001",--12530001 --beq $a2, $a3, increment_cnt
    B"000010_00000000000000000000000100",  --20000004 --j continue
    B"001000_10100_10100_0000000000000001",--22940001 --addi $a4,$a4,1
    B"000010_00000000000000000000000100",  --20000004 --j continue
    B"001100_10100_10100_0000000000000001",--32940001 --andi $a4, $a4, 1 #resetam la 1 contorul
    B"000000_00000_10010_10011_00000_100000",--00129820 --add $a3, $zero, $a2
    B"000010_00000000000000000000000100",  --20000004 --j continue
    B"000100_10010_00000_0000000000000110",--12400006 --beq $a2,$zero, isMultipleof5_true
    B"000000_00000_10010_11000_00000_100000",--0012C020 -- add $s0, $zero, $a2
    B"000000_11000_11000_1111111111111011",--318FFFB --addi $s0, $s0, -5
    B"000100_11000_00000_0000000000000100",--13000004 --beq $s0,$zero, isMultipleof5_true
    B"001010_11000_11001_0000000000000101",--2B190005 --slti $s1,$s0,5
    B"000101_11001_00000_0000000000000011",--17200003 --bne $s1,$zero,isMultipleof5_false
    B"000010_00000000000000000000010100",  --20000014 -- j loop
    B"001000_00000_00001_0000000000000001",--20010001 --addi $v0, $zero, 1
    B"000010_00000000000000000000001000",  --20000008 --j process
    B"001000_00000_00001_0000000000000000",--20010000 --addi $v0, $zero, 0
    B"000010_00000000000000000000001000",  --20000008 --j process
    others => (others => '0')
);

begin
    -- PC
    process(clk, en, reset)
    begin
        if reset = '1' then
            pc_out <= x"00000000";
        else
            if rising_edge(clk) then
                if en = '1' then
                    pc_out <= mux2_out;
                end if;
            end if;
        end if;
    end process;
    
    -- sumator 
    sum_out <= pc_out + 1;
    
    -- memoria de instructiuni
    current_instr <= rom(conv_integer(pc_out));
    
    PCInc <= sum_out;
    
    -- mux1
    mux1_out <= sum_out when PCSrc = '0'
                else branch_addr;
    
    -- mux2
    mux2_out <= mux1_out when jump = '0'
                else jmp_addr;

end Behavioral;
