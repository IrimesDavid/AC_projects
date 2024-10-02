----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/29/2021 06:38:26 PM
-- Design Name: 
-- Module Name: ID - Behavioral
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

entity InstructionDecode is
  Port (
        clk: in std_logic;
        Instr: in std_logic_vector(25 downto 0);
        RegWrite: in std_logic;
        RegDst: in std_logic;
        Rdata1: out std_logic_vector(31 downto 0);
        Rdata2: out std_logic_vector(31 downto 0);
        Wdata: in std_logic_vector(31 downto 0);
        ExtOp: in std_logic;
        ExtImm: out std_logic_vector(31 downto 0);
        func: out std_logic_vector(5 downto 0);
        sa: out std_logic_vector(4 downto 0)
        );
end InstructionDecode;

architecture Behavioral of InstructionDecode is

type regArray is array(0 to 31) of std_logic_vector(31 downto 0); 
signal reg : regArray:= (  
    others => X"00000000"
); 
signal Waddr: std_logic_vector(4 downto 0);
signal rs: std_logic_vector(4 downto 0);
signal rt: std_logic_vector(4 downto 0);
signal rd: std_logic_vector(4 downto 0);

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if RegWrite = '1' then
                reg(conv_integer(Waddr)) <= Wdata;
            end if;
        end if;
    end process;
    
    Rdata1 <= reg(conv_integer(Instr(25 downto 21)));
    Rdata2 <= reg(conv_integer(Instr(20 downto 16)));
    
    mux: Waddr <= Instr(20 downto 16) when RegDst = '0' else Instr(15 downto 11);
    
    sa <= Instr(10 downto 6);
    func <= Instr(5 downto 0);
    
    ExtImm(15 downto 0) <= Instr(15 downto 0);
    ExtImm(31 downto 16) <= (others => Instr(15)) when ExtOp = '1' else
    (others => '0');
        
        
    --registrele s,t,d
    rs <= Instr(25 downto 21);
    rt <= Instr(20 downto 16);
    rd <= Instr(15 downto 11);
end Behavioral;
