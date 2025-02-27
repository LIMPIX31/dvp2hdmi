module rgb_transfer (
    input  logic dvp_clk,
    output logic tmds_clk,
    input  logic rst_n,

    input  logic [ 7:0] dvp_pixel,
    output logic [23:0] tmds_pixel
);

    logic [7:0] rgp;

    always_ff @(posedge dvp_clk) begin
        rgp <= dvp_pixel;
    end

    CLKDIV u_clk_div2 (
        .CLKOUT(tmds_clk),
        .HCLKIN(dvp_clk),
        .CALIB (1'b0),
        .RESETN(rst_n)
    );

    always_ff @(posedge tmds_clk) begin
        tmds_pixel[23:16] <= {3'b0, rgp[7:3]} * 8'd8;
        tmds_pixel[15:8]  <= {2'b0, rgp[2:0], dvp_pixel[7:5]} * 8'd4;
        tmds_pixel[7:0]   <= {3'b0, dvp_pixel[4:0]} * 8'd8;
    end

endmodule : rgb_transfer
