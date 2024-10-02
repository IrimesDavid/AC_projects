----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.03.2024 08:47:47
-- Design Name: 
-- Module Name: lab3 - Behavioral
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

entity lab3 is
    Port ( clk : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0)
           );
end lab3;

architecture Behavioral of lab3 is

signal enable: std_logic;
signal reset: std_logic;
signal instruction, PCInc_s: std_logic_vector(31 downto 0);
signal digits: std_logic_vector(31 downto 0);

component MPG
     Port (
     en: out STD_LOGIC;
     input: in STD_LOGIC;
     clock: in STD_LOGIC
     );
end component;

component SSD
    Port ( 
           clock : in STD_LOGIC;
           anod : out STD_LOGIC_VECTOR (7 downto 0);
           catod : out STD_LOGIC_VECTOR (6 downto 0);
           digits: in STD_LOGIC_VECTOR (31 downto 0)
    );
end component;

component InstructionFetch is
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
end component;

component InstructionDecode is
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
end component;

component UC is
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
end component;

component InstructionExecution is
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
end component;

component MEM is
   Port ( 
        clk :       in STD_LOGIC;
        MemWrite :  in STD_LOGIC;
        Addr :      in STD_LOGIC_VECTOR (31 downto 0);
        Wdata :    in STD_LOGIC_VECTOR (31 downto 0);
        MEMdata :    out STD_LOGIC_VECTOR (31 downto 0);
        ALURes : out STD_LOGIC_VECTOR (31 downto 0)
        );
end component;

component WB is
  Port (
       MEMtoReg: in std_logic;
       MEMData: in std_logic_vector(31 downto 0);
       ALURes: in std_logic_vector(31 downto 0);
       WData: out std_logic_vector(31 downto 0)
       );
end component;

signal branch_addr_s: STD_LOGIC_VECTOR (31 downto 0);
signal jmp_addr_s: STD_LOGIC_VECTOR (31 downto 0);
signal PCSrc_s: STD_LOGIC;
signal RegWrite_s: std_logic;
signal RegDst_s: std_logic;
signal rd1: std_logic_vector(31 downto 0);
signal rd2: std_logic_vector(31 downto 0);
signal wd: std_logic_vector(31 downto 0);
signal ExtOp_s: std_logic;
signal ExtImm_s: std_logic_vector(31 downto 0);
signal func_s: std_logic_vector(5 downto 0);
signal sa_s: std_logic_vector(4 downto 0);
signal zero_s: std_logic;
signal ALUSrc_F : std_logic;
signal ALURes_s : std_logic_vector(31 downto 0);
signal Branch_F : std_logic;
signal Bne_F : std_logic;
signal Jump_F : std_logic;
signal ALUOp_F : std_logic_vector(2 downto 0);
signal MemWrite_F : std_logic;
signal MemtoReg_F : std_logic;
signal MEMData_s: std_logic_vector(31 downto 0);
signal ALURes_out: std_logic_vector(31 downto 0);

begin
    ssdInstance: SSD port map(clk, an, cat, digits);   
    mpgInstance1 : MPG port map(enable, btn(0), clk);
    mpgInstance2 : MPG port map(reset, btn(1), clk);
    IFInstance : InstructionFetch port map(clk, enable, reset, branch_addr_s, jmp_addr_s, Jump_F, PCSrc_s, Instruction, PCInc_s);
    IDInstance: InstructionDecode port map(clk, Instruction(25 downto 0), RegWrite_s, RegDst_s, rd1, rd2, wd, ExtOp_s, ExtImm_s, func_s, sa_s);
    UCInstance: UC port map(Instruction(31 downto 26), RegDst_s, ExtOp_s, ALUSrc_F, Branch_F, Bne_F, Jump_F, ALUOp_F, MemWrite_F, MemtoReg_F, RegWrite_s);
    EXInstance: InstructionExecution port map(PCInc_s, rd1, rd2, ExtImm_s, func_s, sa_s, ALUSrc_F, ALUOp_F, branch_addr_s, ALURes_s, zero_s);
    MEMInstance: MEM port map(clk, MEMWrite_F, ALURes_s, rd2, MEMData_s, ALURes_out);
    WBInstance: WB port map(MemtoReg_F, MEMData_s, ALURes_out, wd);
    
    --branch control
    PCSrc_s <= (zero_s and Branch_F) or (not(zero_s) and Bne_F);
    
    --jump adress
    jmp_addr_s <= "000000" & Instruction(25 downto 0);
    
    process(sw)
    begin
        case(sw(8 downto 5)) is
            when "0000" => digits <= Instruction;
            when "0001" => digits <= PCInc_s;
            when "0010" => digits <= rd1;
            when "0011" => digits <= rd2;
            when "0100" => digits <= ExtImm_s;
            when "0101" => digits <= ALURes_s;
            when "0110" => digits <= MEMData_s;
            when "0111" => digits <= wd;
            when "1000" => digits <= "0000000000000000000000000000000" & Jump_F;
            when "1001" => digits <= jmp_addr_s;
            when others => digits <= X"00000000";
        end case;
    end process;
 
--TODO: pot sa verific daca Instruction este un sir de 0 si daca da, sa activez un led care reprezinta terminarea programului
--in ID pot sa mai adaug o iesire pe care o portmapez aici numita RES, unde retin valoarea registrului $a4("10100"), 
--care retine de fapt rezultatul final. Pot sa afisez continutul lui RES pentru o anumita combinatie de switch-uri.
end Behavioral;