module top
    import h14tx_pkg::timings_cfg_t;
(
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

    output logic led_dvp,
    output logic led_delock
);

    assign twi_mux = 3'b101;
    assign dvp_power_down = 1'b0;
    assign dvp_rst_n = rst_n;

    logic dvp_ready;

    dvp_pll u_dvp_pll (
        .ref_clk(ref_clk),
        .rst_n  (rst_n),

        .dvp_clk(dvp_ref_clk)
    );

    dvp_init u_dvp_init (
        .clk  (ref_clk),
        .rst_n(rst_n),
        .scl  (dvp_scl),
        .sda  (dvp_sda),
        .done (dvp_ready)
    );

    logic vsync_front;

    edge_detector u_vsync_edge_detector (
        .clk(dvp_pixel_clk),
        .signal(dvp_vsync),
        .front(vsync_front)
    );

    logic [5:0] frame_counter;
    logic vsync_flip;

    always_ff @(posedge dvp_pixel_clk or negedge rst_n) begin
        if (!rst_n) begin
            frame_counter <= 0;
            vsync_flip <= 1;
        end else if (frame_counter == 6'd59) begin
            frame_counter <= 0;
            vsync_flip <= ~vsync_flip;
        end else if (vsync_front && dvp_vsync) begin
            frame_counter <= frame_counter + 6'b1;
        end
    end

    assign led_dvp = dvp_ready ? vsync_flip : 1'b0;

    logic tmds_clk;
    logic [23:0] tmds_pixel;

    rgb_transfer u_rgb_transfer (
        .dvp_clk(dvp_pixel_clk),
        .tmds_clk(tmds_clk),
        .rst_n(rst_n),
        .dvp_pixel(dvp_data),
        .tmds_pixel(tmds_pixel)
    );

    logic tmds_pll_lock;
    logic serial_tmds_clk;

    tmds_pll u_tmds_pll (
        .tmds_clk(dvp_pixel_clk),        
        .rst_n(rst_n),
        .lock(tmds_pll_lock),
        .serial_tmds_clk(serial_tmds_clk)
    );

    logic de_front;

    edge_detector u_de_edge_detector (
        .clk(tmds_clk),
        .signal(dvp_de),
        .front(de_front)
    );

    logic de_lock;

    always_ff @(posedge tmds_clk or negedge rst_n) begin
        if (!rst_n) begin
            de_lock <= 0;
        end else begin
            de_lock <= de_lock || (tmds_pll_lock && de_front && dvp_de);
        end
    end

    assign led_delock = de_lock;

    logic tmds_rst_n;

    assign tmds_rst_n = rst_n && de_lock;

    localparam timings_cfg_t TimingsCfg = '{1650, 750, 1280, 720, 110, 40, 5, 5, 1'b0};

    logic [11:0] x;
    logic [10:0] y;

    h14tx_rgb #(TimingsCfg) u_rgb (
        .pixel_clk(tmds_clk),
        .serial_clk(serial_tmds_clk),
        .rst_n(de_lock),
        .rgb(tmds_pixel),
        .x(x),
        .y(y),
        .tmds(
        '{
            '{tmds_clk_p, tmds_clk_n},
            {
                '{tmds_chan_p[2], tmds_chan_n[2]},
                '{tmds_chan_p[1], tmds_chan_n[1]},
                '{tmds_chan_p[0], tmds_chan_n[0]}
            }
        }
        )
    );

endmodule : top
