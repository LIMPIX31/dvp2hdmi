module sys_pll (
    input logic ref_clk,
    input logic rst_n,

    input  logic dvp_clk_en,
    output logic dvp_clk
);

    logic lock;

    logic gw_vcc, gw_gnd;

    assign gw_vcc = 1'b1;
    assign gw_gnd = 1'b0;

    logic [6:0] sink;

    PLL #(
        .FCLKIN("50"),
        .IDIV_SEL(1),
        .ODIV0_SEL(50),
        .MDIV_SEL(24),
        .CLKOUT0_EN("TRUE")
    ) u_pll_serial (
        .LOCK(lock),
        .CLKOUT0(dvp_clk),
        .CLKOUT1(sink[0]),
        .CLKOUT2(sink[1]),
        .CLKOUT3(sink[2]),
        .CLKOUT4(sink[3]),
        .CLKOUT5(sink[4]),
        .CLKOUT6(sink[5]),
        .CLKFBOUT(sink[6]),
        .CLKIN(ref_clk),
        .CLKFB(gw_gnd),
        .RESET(~rst_n),
        .PLLPWD(gw_gnd),
        .RESET_I(gw_gnd),
        .RESET_O(gw_gnd),
        .FBDSEL({gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd}),
        .IDSEL({gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd}),
        .MDSEL({gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd}),
        .MDSEL_FRAC({gw_gnd, gw_gnd, gw_gnd}),
        .ODSEL0({gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd}),
        .ODSEL0_FRAC({gw_gnd, gw_gnd, gw_gnd}),
        .ODSEL1({gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd}),
        .ODSEL2({gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd}),
        .ODSEL3({gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd}),
        .ODSEL4({gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd}),
        .ODSEL5({gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd}),
        .ODSEL6({gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd}),
        .DT0({gw_gnd, gw_gnd, gw_gnd, gw_gnd}),
        .DT1({gw_gnd, gw_gnd, gw_gnd, gw_gnd}),
        .DT2({gw_gnd, gw_gnd, gw_gnd, gw_gnd}),
        .DT3({gw_gnd, gw_gnd, gw_gnd, gw_gnd}),
        .ICPSEL({gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd}),
        .LPFRES({gw_gnd, gw_gnd, gw_gnd}),
        .LPFCAP({gw_gnd, gw_gnd}),
        .PSSEL({gw_gnd, gw_gnd, gw_gnd}),
        .PSDIR(gw_gnd),
        .PSPULSE(gw_gnd),
        .ENCLK0(dvp_clk_en),
        .ENCLK1(gw_vcc),
        .ENCLK2(gw_vcc),
        .ENCLK3(gw_vcc),
        .ENCLK4(gw_vcc),
        .ENCLK5(gw_vcc),
        .ENCLK6(gw_vcc),
        .SSCPOL(gw_gnd),
        .SSCON(gw_gnd),
        .SSCMDSEL({gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd, gw_gnd}),
        .SSCMDSEL_FRAC({gw_gnd, gw_gnd, gw_gnd})
    );

endmodule : sys_pll
