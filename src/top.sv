module top (
    input logic ref_clk,
    input logic rst_n,

    output logic [2:0] twi_mux,

    output logic dvp_scl,
    inout  logic dvp_sda,
    input  logic dvp_vsync,
    input  logic dvp_de,
    input  logic dvp_pixel_clk,
    output logic dvp_ref_clk,
    output logic dvp_rst_n,
    output logic dvp_power_down,

    input logic [7:0] dvp_data,

    output logic tmds_clk_p,
    output logic tmds_clk_n,

    output logic [2:0] tmds_chan_p,
    output logic [2:0] tmds_chan_n,

    output logic led_dvp_ready
);

    assign twi_mux = 3'b101;
    assign dvp_power_down = 1'b0;
    assign dvp_rst_n = rst_n;
//    assign dvp_ref_clk = ref_clk;
 
    logic dvp_ready;

    sys_pll u_sys_pll (
        .ref_clk(ref_clk),
        .rst_n(rst_n),

        .dvp_clk(dvp_ref_clk)
    );

    assign led_dvp_ready = dvp_ready;

    dvp_init u_dvp_init (
        .clk  (ref_clk),
        .rst_n(rst_n),
        .scl  (dvp_scl),
        .sda  (dvp_sda),
        .done (dvp_ready)
    );

endmodule : top
