// Copyright (c) 2025 Sigma Logic
//
// h14tx v1.0
// Core by @LIMPIX31
// 
// HDMI 1.4 Video Transmitter

// h14tx_pkg.sv
package h14tx_pkg;

    localparam integer BitWidth = 12;
    localparam integer BitHeight = 11;

    typedef enum logic [1:0] {
        Control,
        VideoActive,
        VideoPreamble,
        VideoGuard
    } period_t;

    typedef struct packed {
        int   frame_width;
        int   frame_height;
        int   active_width;
        int   active_height;
        int   h_front_porch;
        int   h_sync_width;
        int   v_front_porch;
        int   v_sync_width;
        logic invert_polarity;
    } timings_cfg_t;

    typedef struct packed {
        lvds_pkg::pair_t clk;
        lvds_pkg::pair_t [2:0] chan;
    } tmds_t;

endpackage : h14tx_pkg

// h14tx_timings.sv
module h14tx_timings
    import h14tx_pkg::timings_cfg_t;
    import h14tx_pkg::BitWidth;
    import h14tx_pkg::BitHeight;
    import h14tx_pkg::period_t;
    import h14tx_pkg::Control;
    import h14tx_pkg::VideoActive;
    import h14tx_pkg::VideoPreamble;
    import h14tx_pkg::VideoGuard;
#(
    parameter timings_cfg_t Cfg = '{1650, 750, 1280, 720, 110, 40, 5, 5, 1'b0},

    parameter logic [BitWidth-1:0] FrameWidth = BitWidth'(Cfg.frame_width),
    parameter logic [BitHeight-1:0] FrameHeight = BitHeight'(Cfg.frame_height),
    parameter logic [BitWidth-1:0] ActiveWidth = BitWidth'(Cfg.active_width),
    parameter logic [BitHeight-1:0] ActiveHeight = BitHeight'(Cfg.active_height),
    parameter logic [BitWidth-1:0] HFrontPorch = BitWidth'(Cfg.h_front_porch),
    parameter logic [BitWidth-1:0] HSyncWidth = BitWidth'(Cfg.h_sync_width),
    parameter logic [BitHeight-1:0] VFrontPorch = BitHeight'(Cfg.v_front_porch),
    parameter logic [BitHeight-1:0] VSyncWidth = BitHeight'(Cfg.v_sync_width),
    parameter logic InvertPolarity = Cfg.invert_polarity
) (
    input logic clk,
    input logic rst_n,

    output logic [ BitWidth-1:0] x,
    output logic [BitHeight-1:0] y,

    output logic hsync,
    output logic vsync,

    output period_t period
);

    // Advance cursor
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x <= 0;
            y <= 0;
        end else begin
            x <= x == FrameWidth - BitWidth'(1) ? BitWidth'(0) : x + BitWidth'(1);
            y <= x == FrameWidth - BitWidth'(1) ? (y == FrameHeight - BitHeight'(1) ? BitHeight'(0) : y + BitHeight'(1)) : y;
        end
    end

    // The timings looks like this (_ - blanking or data island, v - video, p - preamble,
    // g - guard, h - hsync, y - vsync, x - both vsync and hsync)
    // vvvvvvvvvvvvvvvvvvvvvvvv__h_pg
    // vvvvvvvvvvvvvvvvvvvvvvvv__h_pg
    // vvvvvvvvvvvvvvvvvvvvvvvv__h_pg
    // vvvvvvvvvvvvvvvvvvvvvvvv__h_pg
    // vvvvvvvvvvvvvvvvvvvvvvvv__h___
    // __________________________xyyy
    // yyyyyyyyyyyyyyyyyyyyyyyyyyxyyy
    // yyyyyyyyyyyyyyyyyyyyyyyyyyh_pg

    // Determine Horizontal Sync Pulse Range
    localparam [BitWidth-1:0] HSyncStart = ActiveWidth + HFrontPorch;
    localparam [BitWidth-1:0] HSyncEnd = HSyncStart + HSyncWidth;

    // Determine Vertical Sync Pulse Range
    localparam [BitHeight-1:0] VSyncStart = ActiveHeight + VFrontPorch;
    localparam [BitHeight-1:0] VSyncEnd = VSyncStart + VSyncWidth;

    always_comb begin
        hsync = x >= HSyncStart && x < HSyncEnd;

        if (y == VSyncStart) begin
            vsync = x >= HSyncStart;
        end else if (y == VSyncEnd - BitHeight'(1)) begin
            vsync = x < HSyncStart;
        end else begin
            vsync = y >= VSyncStart && y < VSyncEnd;
        end
    end

    // Periods boundaries
    localparam [BitWidth-1:0] VideoPreambleStart = FrameWidth - BitWidth'(10);
    localparam [BitWidth-1:0] VideoGuardStart = FrameWidth - BitWidth'(2);

    // Put video preamble at end of each active line except last one
    // and put on the end of the last frame line
    logic preamble_line;
    assign preamble_line = y < ActiveHeight - BitHeight'(1) || y == FrameHeight - BitHeight'(1);

    // Pick Period
    always_comb begin
        if (x < ActiveWidth && y < ActiveHeight) begin
            period = VideoActive;
        end else if (preamble_line && (x >= VideoPreambleStart && x < VideoGuardStart)) begin
            period = VideoPreamble;
        end else if (preamble_line && (x >= VideoGuardStart && x < FrameWidth)) begin
            period = VideoGuard;
        end else begin
            // Pick control period for the rest of time
            period = Control;
        end
    end

endmodule : h14tx_timings

// h14tx_tmds8b10b.sv
module h14tx_tmds8b10b (
    input logic clk,
    input logic rst_n,

    input logic enable,
    input logic [7:0] video,

    output logic [9:0] symbol
);

    logic signed [4:0] disparity;
    logic [8:0] ir;

    logic [3:0] n1d;
    logic signed [4:0] n1ir;
    logic signed [4:0] n0ir;

    assign n1d  = 4'($countones(video));
    assign n1ir = 5'($countones(ir[7:0]));
    assign n0ir = 5'sd8 - 5'($countones(ir[7:0]));

    logic signed [4:0] dispadd;

    logic [9:0] next_symbol;

    always_comb begin
        ir[0] = video[0];

        if (n1d > 4'd4 || (n1d == 4'd4 && video[0] == 1'b0)) begin
            ir[1] = ir[0] ~^ video[1];
            ir[2] = ir[1] ~^ video[2];
            ir[3] = ir[2] ~^ video[3];
            ir[4] = ir[3] ~^ video[4];
            ir[5] = ir[4] ~^ video[5];
            ir[6] = ir[5] ~^ video[6];
            ir[7] = ir[6] ~^ video[7];

            ir[8] = 1'b0;
        end else begin
            ir[1] = ir[0] ^ video[1];
            ir[2] = ir[1] ^ video[2];
            ir[3] = ir[2] ^ video[3];
            ir[4] = ir[3] ^ video[4];
            ir[5] = ir[4] ^ video[5];
            ir[6] = ir[5] ^ video[6];
            ir[7] = ir[6] ^ video[7];

            ir[8] = 1'b1;
        end

        if (disparity == 5'sd0 || (n1ir == n0ir)) begin
            next_symbol = {~ir[8], ir[8], ir[8] ? ir[7:0] : ~ir[7:0]};
            dispadd = ir[8] ? n1ir - n0ir : n0ir - n1ir;
        end else if ((disparity > 5'sd0 && n1ir > n0ir) || (disparity < 5'sd0 && n1ir < n0ir)) begin
            next_symbol = {1'b1, ir[8], ~ir[7:0]};
            dispadd = (n0ir - n1ir) + (ir[8] ? 5'sd2 : 5'sd0);
        end else begin
            next_symbol = {1'b0, ir[8], ir[7:0]};
            dispadd = (n1ir - n0ir) - (~ir[8] ? 5'sd2 : 5'sd0);
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || !enable) begin
            disparity <= 0;
            symbol <= 10'b0;
        end else begin
            disparity <= disparity + dispadd;
            symbol <= next_symbol;
        end
    end

endmodule : h14tx_tmds8b10b

// h14tx_channel.sv
module h14tx_channel
    import h14tx_pkg::period_t;
    import h14tx_pkg::VideoActive;
    import h14tx_pkg::VideoGuard;
#(
    parameter bit [1:0] Chan = 0
) (
    input logic clk,
    input logic rst_n,

    input period_t period,

    input logic [1:0] ctl,
    input logic [7:0] video,

    output logic [9:0] symbol
);

    logic [9:0] ctl_s;

    // Encode Control symbol
    always_comb
        unique case (ctl)
            2'b00: ctl_s = 10'b1101010100;
            2'b01: ctl_s = 10'b0010101011;
            2'b10: ctl_s = 10'b0101010100;
            2'b11: ctl_s = 10'b1010101011;
        endcase

    logic [9:0] video_s;

    // Encode Active video
    h14tx_tmds8b10b u_tmds8b10b (
        .clk(clk),
        .rst_n(rst_n),
        .enable(period == VideoActive),
        .video(video),
        .symbol(video_s)
    );

    logic [9:0] guard_s;

    // Set Guard Band
    always_comb
        unique case (Chan)  /*synthesis full_case*/
            0: guard_s = 10'b1011001100;
            1: guard_s = 10'b0100110011;
            2: guard_s = 10'b1011001100;
        endcase

    // Pick symbol based on current period
    always_comb
        case (period)
            VideoActive: symbol = video_s;
            VideoGuard: symbol = guard_s;
            default: symbol = ctl_s;
        endcase

endmodule : h14tx_channel

// h14tx_serdes.sv
module h14tx_serdes
    import h14tx_pkg::tmds_t;
#(
    parameter string LvdsMode = "Emulated"
) (
    input logic serial_clk,
    input logic pixel_clk,
    input logic rst,

    input logic [2:0][9:0] chan,

    output tmds_t tmds
);

    generate
        for (genvar i = 0; i < 3; i++) begin : gen_oser10
            logic serialized_chan;

            OSER10 u_chan_serde (
                .Q(serialized_chan),
                .D0(chan[i][0]),
                .D1(chan[i][1]),
                .D2(chan[i][2]),
                .D3(chan[i][3]),
                .D4(chan[i][4]),
                .D5(chan[i][5]),
                .D6(chan[i][6]),
                .D7(chan[i][7]),
                .D8(chan[i][8]),
                .D9(chan[i][9]),
                .PCLK(pixel_clk),
                .FCLK(serial_clk),
                .RESET(rst)
            );

            lvds_out #(LvdsMode) u_chan_lvds_out (
                .single(serialized_chan),
                .pair  (tmds.chan[i])
            );
        end
    endgenerate

    logic serialized_clk;

    OSER10 u_clk_serde (
        .Q(serialized_clk),
        .D0(1'b1),
        .D1(1'b1),
        .D2(1'b1),
        .D3(1'b1),
        .D4(1'b1),
        .D5(1'b0),
        .D6(1'b0),
        .D7(1'b0),
        .D8(1'b0),
        .D9(1'b0),
        .PCLK(pixel_clk),
        .FCLK(serial_clk),
        .RESET(rst)
    );

    lvds_out #(LvdsMode) u_clk_lvds_out (
        .single(serialized_clk),
        .pair  (tmds.clk)
    );

endmodule : h14tx_serdes

// h14tx_rgb.sv
module h14tx_rgb
    import h14tx_pkg::timings_cfg_t;
    import h14tx_pkg::tmds_t;
    import h14tx_pkg::period_t;
    import h14tx_pkg::VideoPreamble;
#(
    parameter timings_cfg_t TimingsCfg = '{1650, 750, 1280, 720, 110, 40, 5, 5, 1'b0}
) (
    input logic pixel_clk,
    input logic serial_clk,
    input logic rst_n,

    input logic [2:0][7:0] rgb,

    output logic [h14tx_pkg::BitWidth-1:0] x,
    output logic [h14tx_pkg::BitHeight-1:0] y,

    output tmds_t tmds
);

    logic hsync, vsync;

    period_t period;

    h14tx_timings #(TimingsCfg) u_timings (
        .clk(pixel_clk),
        .rst_n(rst_n),
        .x(x),
        .y(y),
        .hsync(hsync),
        .vsync(vsync),
        .period(period)
    );

    logic [2:0][1:0] ctl;

    assign ctl[0] = {vsync, hsync};
    assign ctl[2:1] = period == VideoPreamble ? 4'b0001 : 4'b0000;

    logic [2:0][9:0] chan;

    generate
        for (genvar i = 0; i < 3; i++) begin : gen_channel
            h14tx_channel #(i) u_channel (
                .clk(pixel_clk),
                .rst_n(rst_n),
                .period(period),
                .ctl(ctl[i]),
                .video(rgb[i]),
                .symbol(chan[i])
            );
        end
    endgenerate

    h14tx_serdes u_serdes (
        .serial_clk(serial_clk),
        .pixel_clk(pixel_clk),
        .rst(~rst_n),
        .chan(chan),
        .tmds(tmds)
    );

endmodule : h14tx_rgb
