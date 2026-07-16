-- Register_Cluster.vhd
-- Created on: So 13. Nov 19:06:55 CET 2022
-- Author(s): Nina Chlóe Kassandra Reiß <nina.reiss@nickr.eu>
-- Content:  Entity Register_Cluster
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.riscv_types.all;


entity Register_Cluster is
    generic (
        Empty_Cluster      :     regFile := (others => (others => '0'))
    );
    port (
        Clock              : in  std_logic;
        Reset_N            : in  std_logic;
        Write_Data         : in  word;
        Register_ID_Write  : in  reg_idx;
        Register_ID_Read_1 : in  reg_idx;
        Register_ID_Read_2 : in  reg_idx;
        Enable_Writeback   : in  std_logic;
        Read_Data_1        : out word;
        Read_Data_2        : out word
    );
end entity Register_Cluster;

architecture Structure of Register_Cluster is
    signal Cluster : regFile;
begin

    process (Clock, Reset_N) is
    begin
        if Reset_N = '0' then
            Cluster                                              <= Empty_Cluster;
        elsif rising_edge(Clock) then
            if Enable_Writeback = '1' then
                Cluster(to_integer(unsigned(Register_ID_Write))) <= Write_Data;
            end if;
            Cluster(0)                                           <= (others => '0');
        end if;
    end process;

    Read_Data_1                                                  <= Cluster(to_integer(unsigned(Register_ID_Read_1)));
    Read_Data_2                                                  <= Cluster(to_integer(unsigned(Register_ID_Read_2)));

end architecture Structure;
