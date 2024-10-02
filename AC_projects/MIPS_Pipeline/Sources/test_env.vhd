----------------------------------------------------------------------------------
-- Company: Technical University of Cluj-Napoca 
-- Engineer: Cristian Vancea
-- 
-- Module Name: test_env - Behavioral
-- Description: 
--      MIPS 32, single-cycle
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

component MPG is
    Port ( enable : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC);
end component;

component SSD is
    Port ( clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;

component IFetch
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           en : in STD_LOGIC;
           BranchAddress : in STD_LOGIC_VECTOR(31 downto 0);
           JumpAddress : in STD_LOGIC_VECTOR(31 downto 0);
           Jump : in STD_LOGIC;
           PCSrc : in STD_LOGIC;
           Instruction : out STD_LOGIC_VECTOR(31 downto 0);
           PCp4 : out STD_LOGIC_VECTOR(31 downto 0));
end component;

component ID
    Port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;    
           Instr : in STD_LOGIC_VECTOR(25 downto 0);
           WD : in STD_LOGIC_VECTOR(31 downto 0);
           RegWrite : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           RD1 : out STD_LOGIC_VECTOR(31 downto 0);
           RD2 : out STD_LOGIC_VECTOR(31 downto 0);
           Ext_Imm : out STD_LOGIC_VECTOR(31 downto 0);
           func : out STD_LOGIC_VECTOR(5 downto 0);
           sa : out STD_LOGIC_VECTOR(4 downto 0);
           WriteAddr : in STD_LOGIC_VECTOR(4 downto 0));
end component;

component UC
    Port ( Instr : in STD_LOGIC_VECTOR(5 downto 0);
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           ALUSrc : out STD_LOGIC;
           Branch : out STD_LOGIC;
           Jump : out STD_LOGIC;
           ALUOp : out STD_LOGIC_VECTOR(2 downto 0);
           MemWrite : out STD_LOGIC;
           MemtoReg : out STD_LOGIC;
           RegWrite : out STD_LOGIC;
           ID_EX_Rt: in STD_LOGIC_VECTOR(4 downto 0);
           ID_EX_Rs: in STD_LOGIC_VECTOR(4 downto 0);
           EX_MEM_Rd: in STD_LOGIC_VECTOR(4 downto 0);
           EX_MEM_RegWrite: in std_logic;
           ForwardA: out std_logic;
           ForwardB: out std_logic);
end component;

component EX is
    Port ( PCp4 : in STD_LOGIC_VECTOR(31 downto 0);
           RD1 : in STD_LOGIC_VECTOR(31 downto 0);
           RD2 : in STD_LOGIC_VECTOR(31 downto 0);
           Ext_Imm : in STD_LOGIC_VECTOR(31 downto 0);
           func : in STD_LOGIC_VECTOR(5 downto 0);
           sa : in STD_LOGIC_VECTOR(4 downto 0);
           ALUSrc : in STD_LOGIC;
           ALUOp : in STD_LOGIC_VECTOR(2 downto 0);
           BranchAddress : out STD_LOGIC_VECTOR(31 downto 0);
           ALURes : out STD_LOGIC_VECTOR(31 downto 0);
           Zero : out STD_LOGIC;
           WriteAddr : out STD_LOGIC_VECTOR(4 downto 0);
           RegDst : in STD_LOGIC;
           RA1 : in STD_LOGIC_VECTOR(4 downto 0);
           RA2 : in STD_LOGIC_VECTOR(4 downto 0);
           ForwardA: in STD_LOGIC;
           ForwardB: in STD_LOGIC;
           Forwarded_ALURes: in STD_LOGIC_VECTOR(31 downto 0));
end component;

component MEM
    port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           ALUResIn : in STD_LOGIC_VECTOR(31 downto 0);
           RD2 : in STD_LOGIC_VECTOR(31 downto 0);
           MemWrite : in STD_LOGIC;			
           MemData : out STD_LOGIC_VECTOR(31 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR(31 downto 0));
end component;

--registers
signal IF_ID : STD_LOGIC_VECTOR(63 downto 0);
signal ID_EX : STD_LOGIC_VECTOR(162 downto 0);
signal EX_MEM : STD_LOGIC_VECTOR(105 downto 0);
signal MEM_WB : STD_LOGIC_VECTOR(70 downto 0);

signal Instruction, PCp4, RD1, RD2, WD, Ext_imm : STD_LOGIC_VECTOR(31 downto 0); 
signal JumpAddress, BranchAddress, ALURes, ALURes1, MemData : STD_LOGIC_VECTOR(31 downto 0);
signal func : STD_LOGIC_VECTOR(5 downto 0);
signal sa : STD_LOGIC_VECTOR(4 downto 0);
signal zero : STD_LOGIC;
signal digits : STD_LOGIC_VECTOR(31 downto 0);
signal en, rst, PCSrc : STD_LOGIC; 
-- main controls 
signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite : STD_LOGIC;
signal ALUOp : STD_LOGIC_VECTOR(2 downto 0);

--pipeline additional signals
signal WriteAddress : STD_LOGIC_VECTOR(4 downto 0);
--forwarding signals
signal forwardA, forwardB: STD_LOGIC;

begin
    --register processes
    --IF_ID
    process(clk, btn, en) 
    begin
        if btn(1) = '1' then --reset
            IF_ID <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                IF_ID(31 downto 0) <= PCp4;
                IF_ID(63 downto 32) <= Instruction;
            end if;
        end if;
    end process;
    
    --ID_EX
    process(clk, btn, en)
    begin
        if btn(1) = '1' then
            ID_EX <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                ID_EX(157) <= RegDst;
                ID_EX(156) <= ALUSrc;
                ID_EX(155 downto 153) <= ALUOp;
                ID_EX(152) <= Branch;
                ID_EX(151) <= MemWrite;
                ID_EX(150) <= RegWrite;
                ID_EX(149) <= MemtoReg;
                ID_EX(148 downto 117) <= IF_ID(31 downto 0);--PCp4
                ID_EX(116 downto 85) <= RD1;
                ID_EX(84 downto 53) <= RD2;
                ID_EX(52 downto 48) <= sa;
                ID_EX(47 downto 16) <= Ext_Imm;
                ID_EX(15 downto 10) <= func;
                ID_EX(9 downto 5) <= IF_ID(52 downto 48);--Instr(20:16) = RA2 = rt
                ID_EX(4 downto 0) <= IF_ID(47 downto 43);--Instr(15:11) = rd
                ID_EX(162 downto 158) <= IF_ID(57 downto 53);--Instr(25:21) = rs
            end if;
        end if;
    end process;
    
    --EX_MEM
    process(clk, btn, en)
    begin
        if btn(1) = '1' then
            EX_MEM <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                EX_MEM(105) <= Zero;
                EX_MEM(104) <= ID_EX(152);--Branch
                EX_MEM(103) <= ID_EX(151);--MemWrite
                EX_MEM(102) <= ID_EX(150);--RegWrite
                EX_MEM(101) <= ID_EX(149);--MemtoReg
                EX_MEM(100 downto 69) <= BranchAddress;
                EX_MEM(68 downto 37) <= ALURes;
                EX_MEM(36 downto 5) <= ID_EX(84 downto 53);--RD2
                EX_MEM(4 downto 0) <= WriteAddress;
            end if;
        end if;
    end process;
    
    --MEM_WB
    process(clk, btn, en)
    begin
        if btn(1) = '1' then
            MEM_WB <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                MEM_WB(70) <= EX_MEM(102);--RegWrite
                MEM_WB(69) <= EX_MEM(101);--MemtoReg
                MEM_WB(68 downto 37) <= MemData;
                MEM_WB(36 downto 5) <= EX_MEM(68 downto 37);--sau ALURes1
                MEM_WB(4 downto 0) <= EX_MEM(4 downto 0);--WriteAddress
            end if;
        end if;
    end process;
    
    monopulse : MPG port map(en, btn(0), clk);
    
    -- main units
    inst_IFetch : IFetch port map(clk, btn(1), en, EX_MEM(100 downto 69), JumpAddress, Jump, PCSrc, Instruction, PCp4);
    inst_ID : ID port map(clk, en, IF_ID(57 downto 32), WD, MEM_WB(70), ExtOp, RD1, RD2, Ext_imm, func, sa, MEM_WB(4 downto 0));
    inst_UC : UC port map(IF_ID(63 downto 58), RegDst, ExtOp, ALUSrc, Branch, Jump, ALUOp, MemWrite, MemtoReg, RegWrite, ID_EX(9 downto 5), ID_EX(162 downto 158), EX_MEM(4 downto 0), EX_MEM(102), ForwardA, ForwardB);
    inst_EX : EX port map(ID_EX(148 downto 117), ID_EX(116 downto 85), ID_EX(84 downto 53), ID_EX(47 downto 16), ID_EX(15 downto 10), ID_EX(52 downto 48), ID_EX(156), ID_EX(155 downto 153), BranchAddress, ALURes, Zero, WriteAddress, ID_EX(157), ID_EX(4 downto 0), ID_EX(9 downto 5), ForwardA, ForwardB, EX_MEM(68 downto 37)); 
    inst_MEM : MEM port map(clk, en, EX_MEM(68 downto 37), EX_MEM(36 downto 5), EX_MEM(103), MemData, ALURes1);

    -- Write-Back unit 
    WD <= MEM_WB(68 downto 37) when MEM_WB(69) = '1' else MEM_WB(36 downto 5);

    -- branch control
    PCSrc <= EX_MEM(105) and EX_MEM(104);

    -- jump address
    JumpAddress <= IF_ID(31 downto 28) & IF_ID(57 downto 32) & "00";

   -- SSD display MUX
   --obs: it now displays the latest updated signals (from the newly started instruction)
    with sw(7 downto 5) select
        digits <=  Instruction when "000", 
                   PCp4 when "001",
                   RD1 when "010",
                   RD2 when "011",
                   Ext_Imm when "100",
                   ALURes when "101",
                   MemData when "110",
                   WD when "111",
                   (others => 'X') when others; 

    display : SSD port map(clk, digits, an, cat);
    
    -- main controls on the leds
    --obs: it now displays the latest updated signals (from the newly started instruction)
    led(10 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;
    
end Behavioral;