-------------------------------------------------------------------------------
-- Title      : External Memory controller for SDRAM
-------------------------------------------------------------------------------
-- Description: This module implements a simple, single burst memory controller.
--              User interface is 16 bit (burst of 4), externally 8x 8 bit.
-------------------------------------------------------------------------------
 
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.mem_bus_pkg.all;

entity fpga_mem_test_v5 is
port (
    CLOCK_50        : in    std_logic;

	SDRAM_CLK       : out   std_logic;
	SDRAM_CKE       : out   std_logic;
    SDRAM_CSn       : out   std_logic := '1';
	SDRAM_RASn      : out   std_logic := '1';
	SDRAM_CASn      : out   std_logic := '1';
	SDRAM_WEn       : out   std_logic := '1';
    SDRAM_DQM       : out   std_logic := '0';
    SDRAM_A         : out   std_logic_vector(12 downto 0);
    SDRAM_BA        : out   std_logic_vector(1 downto 0);
    SDRAM_DQ        : inout std_logic_vector(7 downto 0) := (others => 'Z');

    MOTOR_LEDn      : out   std_logic;
    DISK_ACTn       : out   std_logic ); 

end fpga_mem_test_v5;

architecture tb of fpga_mem_test_v5 is
    signal clock       : std_logic := '1';
    signal clk_2x      : std_logic := '1';
    signal reset       : std_logic := '0';
    signal inhibit     : std_logic := '0';
    signal is_idle     : std_logic := '0';
    signal req         : t_mem_req_32 := c_mem_req_32_init;
    signal resp        : t_mem_resp_32;
    signal okay        : std_logic;
    
begin
    i_clk: entity work.s3a_clockgen
    port map (
        clk_50       => CLOCK_50,
        reset_in     => '0',
        
        dcm_lock     => open,
        
        sys_clock    => clock, -- 50 MHz
        sys_reset    => reset,
        sys_clock_2x => clk_2x );

    i_checker: entity work.ext_mem_test_v5
    port map (
        clock       => clock,
        reset       => reset,
        
        req         => req,
        resp        => resp,

        inhibit     => inhibit,
        
        run         => MOTOR_LEDn,
        okay        => okay );

    i_mem_ctrl: entity work.ext_mem_ctrl_v5
	generic map (
		g_simulation => false )
    port map (
        clock       => clock,
        clk_2x      => clk_2x,
        reset       => reset,
    
        inhibit     => inhibit,
        is_idle     => is_idle,
    
        req         => req,
        resp        => resp,
    
    	SDRAM_CLK	=> SDRAM_CLK,
    	SDRAM_CKE	=> SDRAM_CKE,
        SDRAM_CSn   => SDRAM_CSn,
    	SDRAM_RASn  => SDRAM_RASn,
    	SDRAM_CASn  => SDRAM_CASn,
    	SDRAM_WEn   => SDRAM_WEn,
        SDRAM_DQM   => SDRAM_DQM,
    
        SDRAM_BA    => SDRAM_BA,
        SDRAM_A     => SDRAM_A,
        SDRAM_DQ    => SDRAM_DQ );

    DISK_ACTn <= not okay;
end;
