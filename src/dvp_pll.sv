module dvp_pll (
    input logic ref_clk,
    input logic rst_n,

    output logic dvp_clk
);

    logic lock;
    logic [6:0] sink;

    PLL #(
        .FCLKIN("50"),
        .IDIV_SEL(1),
        .ODIV0_SEL(32),
        .MDIV_SEL(16),
        .CLKOUT0_EN("TRUE")
    ) u_pll_0 (
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
        .CLKFB(1'b0),
        .RESET(~rst_n),
        .PLLPWD(1'b0),
        .RESET_I(1'b0),
        .RESET_O(1'b0),
        .FBDSEL({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0}),
        .IDSEL({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0}),
        .MDSEL({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0}),
        .MDSEL_FRAC({1'b0, 1'b0, 1'b0}),
        .ODSEL0({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0}),
        .ODSEL0_FRAC({1'b0, 1'b0, 1'b0}),
        .ODSEL1({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0}),
        .ODSEL2({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0}),
        .ODSEL3({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0}),
        .ODSEL4({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0}),
        .ODSEL5({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0}),
        .ODSEL6({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0}),
        .DT0({1'b0, 1'b0, 1'b0, 1'b0}),
        .DT1({1'b0, 1'b0, 1'b0, 1'b0}),
        .DT2({1'b0, 1'b0, 1'b0, 1'b0}),
        .DT3({1'b0, 1'b0, 1'b0, 1'b0}),
        .ICPSEL({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0}),
        .LPFRES({1'b0, 1'b0, 1'b0}),
        .LPFCAP({1'b0, 1'b0}),
        .PSSEL({1'b0, 1'b0, 1'b0}),
        .PSDIR(1'b0),
        .PSPULSE(1'b0),
        .ENCLK0(1'b1),
        .ENCLK1(1'b1),
        .ENCLK2(1'b1),
        .ENCLK3(1'b1),
        .ENCLK4(1'b1),
        .ENCLK5(1'b1),
        .ENCLK6(1'b1),
        .SSCPOL(1'b0),
        .SSCON(1'b0),
        .SSCMDSEL({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0}),
        .SSCMDSEL_FRAC({1'b0, 1'b0, 1'b0})
    );

endmodule : dvp_pll
