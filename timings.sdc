//Copyright (C)2014-2025 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.11 
//Created Time: 2025-02-26 18:30:51
create_clock -name ref_clk -period 20 -waveform {0 10} [get_ports {ref_clk}]
create_clock -name dvp_pixel_clk -period 6.734 -waveform {0 3.367} [get_ports {dvp_pixel_clk}]
create_generated_clock -name tmds_clk -source [get_ports {dvp_pixel_clk}] -master_clock dvp_pixel_clk -divide_by 2 [get_nets {tmds_clk}]
