module dvp_init #(
    parameter logic [7:0] DevAddr = 8'h78
) (
    input logic clk,
    input logic rst_n,

    output logic scl,
    inout  logic sda,

    output logic done
);

    logic [4:0] twi_counter;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            twi_counter <= 0;
        end else begin
            twi_counter <= twi_counter + 5'b1;
        end
    end

    logic twi_quart;

    assign twi_quart = &twi_counter;

    logic [23:0] rom[1024]; 
    logic [9:0] rom_addr;
    logic [23:0] rom_data;

    always_ff @(posedge clk) begin
        rom_data <= rom[rom_addr];
    end

    initial begin
        $readmemh("progmem.txt", rom);
    end

    logic [20:0] guard;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            guard <= 0;
        end else if (!(&guard)) begin
            guard <= guard + 21'b1;
        end
    end

    logic ack;
    logic twi_sda, twi_scl;

    logic [7:0] state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || !(&guard)) begin
            state <= 0;
            twi_scl <= 1;
            twi_sda <= 1;
            rom_addr <= 0;
            ack <= 0;
            done <= 0;
        end else if (twi_quart && !done && !ack) begin
            case (state)
                // Start Condition
                0:   {twi_sda, twi_scl, state} <= {1'b0, 1'b1, state + 8'b1};
                // DevAddr[7]
                1:   {twi_sda, twi_scl, state} <= {1'b0, 1'b0, state + 8'b1};
                2:   {twi_sda, twi_scl, state} <= {DevAddr[7], 1'b0, state + 8'b1};
                3:   {twi_sda, twi_scl, state} <= {DevAddr[7], 1'b1, state + 8'b1};
                4:   {twi_sda, twi_scl, state} <= {DevAddr[7], 1'b1, state + 8'b1};
                // DevAddr[6]
                5:   {twi_sda, twi_scl, state} <= {DevAddr[7], 1'b0, state + 8'b1};
                6:   {twi_sda, twi_scl, state} <= {DevAddr[6], 1'b0, state + 8'b1};
                7:   {twi_sda, twi_scl, state} <= {DevAddr[6], 1'b1, state + 8'b1};
                8:   {twi_sda, twi_scl, state} <= {DevAddr[6], 1'b1, state + 8'b1};
                // DevAddr[5]
                9:   {twi_sda, twi_scl, state} <= {DevAddr[6], 1'b0, state + 8'b1};
                10:  {twi_sda, twi_scl, state} <= {DevAddr[5], 1'b0, state + 8'b1};
                11:  {twi_sda, twi_scl, state} <= {DevAddr[5], 1'b1, state + 8'b1};
                12:  {twi_sda, twi_scl, state} <= {DevAddr[5], 1'b1, state + 8'b1};
                // DevAddr[4]
                13:  {twi_sda, twi_scl, state} <= {DevAddr[5], 1'b0, state + 8'b1};
                14:  {twi_sda, twi_scl, state} <= {DevAddr[4], 1'b0, state + 8'b1};
                15:  {twi_sda, twi_scl, state} <= {DevAddr[4], 1'b1, state + 8'b1};
                16:  {twi_sda, twi_scl, state} <= {DevAddr[4], 1'b1, state + 8'b1};
                // DevAddr[3]
                17:  {twi_sda, twi_scl, state} <= {DevAddr[4], 1'b0, state + 8'b1};
                18:  {twi_sda, twi_scl, state} <= {DevAddr[3], 1'b0, state + 8'b1};
                19:  {twi_sda, twi_scl, state} <= {DevAddr[3], 1'b1, state + 8'b1};
                20:  {twi_sda, twi_scl, state} <= {DevAddr[3], 1'b1, state + 8'b1};
                // DevAddr[2]
                21:  {twi_sda, twi_scl, state} <= {DevAddr[3], 1'b0, state + 8'b1};
                22:  {twi_sda, twi_scl, state} <= {DevAddr[2], 1'b0, state + 8'b1};
                23:  {twi_sda, twi_scl, state} <= {DevAddr[2], 1'b1, state + 8'b1};
                24:  {twi_sda, twi_scl, state} <= {DevAddr[2], 1'b1, state + 8'b1};
                // DevAddr[1]
                25:  {twi_sda, twi_scl, state} <= {DevAddr[2], 1'b0, state + 8'b1};
                26:  {twi_sda, twi_scl, state} <= {DevAddr[1], 1'b0, state + 8'b1};
                27:  {twi_sda, twi_scl, state} <= {DevAddr[1], 1'b1, state + 8'b1};
                28:  {twi_sda, twi_scl, state} <= {DevAddr[1], 1'b1, state + 8'b1};
                // DevAddr[0]
                29:  {twi_sda, twi_scl, state} <= {DevAddr[1], 1'b0, state + 8'b1};
                30:  {twi_sda, twi_scl, state} <= {DevAddr[0], 1'b0, state + 8'b1};
                31:  {twi_sda, twi_scl, state} <= {DevAddr[0], 1'b1, state + 8'b1};
                32:  {twi_sda, twi_scl, state} <= {DevAddr[0], 1'b1, state + 8'b1};
                // Ack
                33:  {twi_sda, twi_scl, state} <= {1'b1, 1'b0, state + 8'b1};
                34:  {twi_sda, twi_scl, state} <= {1'b1, 1'b0, state + 8'b1};
                35:  {twi_sda, twi_scl, state} <= {1'b1, 1'b1, state + 8'b1};
                36:  {twi_sda, twi_scl, ack, state} <= {1'b1, 1'b1, sda, state + 8'b1};
                // rom_data[23]
                37:  {twi_sda, twi_scl, state} <= {1'b1, 1'b0, state + 8'b1};
                38:  {twi_sda, twi_scl, state} <= {rom_data[23], 1'b0, state + 8'b1};
                39:  {twi_sda, twi_scl, state} <= {rom_data[23], 1'b1, state + 8'b1};
                40:  {twi_sda, twi_scl, state} <= {rom_data[23], 1'b1, state + 8'b1};
                // rom_data[22]
                41:  {twi_sda, twi_scl, state} <= {rom_data[23], 1'b0, state + 8'b1};
                42:  {twi_sda, twi_scl, state} <= {rom_data[22], 1'b0, state + 8'b1};
                43:  {twi_sda, twi_scl, state} <= {rom_data[22], 1'b1, state + 8'b1};
                44:  {twi_sda, twi_scl, state} <= {rom_data[22], 1'b1, state + 8'b1};
                // rom_data[21]
                45:  {twi_sda, twi_scl, state} <= {rom_data[22], 1'b0, state + 8'b1};
                46:  {twi_sda, twi_scl, state} <= {rom_data[21], 1'b0, state + 8'b1};
                47:  {twi_sda, twi_scl, state} <= {rom_data[21], 1'b1, state + 8'b1};
                48:  {twi_sda, twi_scl, state} <= {rom_data[21], 1'b1, state + 8'b1};
                // rom_data[20]
                49:  {twi_sda, twi_scl, state} <= {rom_data[21], 1'b0, state + 8'b1};
                50:  {twi_sda, twi_scl, state} <= {rom_data[20], 1'b0, state + 8'b1};
                51:  {twi_sda, twi_scl, state} <= {rom_data[20], 1'b1, state + 8'b1};
                52:  {twi_sda, twi_scl, state} <= {rom_data[20], 1'b1, state + 8'b1};
                // rom_data[19]
                53:  {twi_sda, twi_scl, state} <= {rom_data[20], 1'b0, state + 8'b1};
                54:  {twi_sda, twi_scl, state} <= {rom_data[19], 1'b0, state + 8'b1};
                55:  {twi_sda, twi_scl, state} <= {rom_data[19], 1'b1, state + 8'b1};
                56:  {twi_sda, twi_scl, state} <= {rom_data[19], 1'b1, state + 8'b1};
                // rom_data[18]
                57:  {twi_sda, twi_scl, state} <= {rom_data[19], 1'b0, state + 8'b1};
                58:  {twi_sda, twi_scl, state} <= {rom_data[18], 1'b0, state + 8'b1};
                59:  {twi_sda, twi_scl, state} <= {rom_data[18], 1'b1, state + 8'b1};
                60:  {twi_sda, twi_scl, state} <= {rom_data[18], 1'b1, state + 8'b1};
                // rom_data[17]
                61:  {twi_sda, twi_scl, state} <= {rom_data[18], 1'b0, state + 8'b1};
                62:  {twi_sda, twi_scl, state} <= {rom_data[17], 1'b0, state + 8'b1};
                63:  {twi_sda, twi_scl, state} <= {rom_data[17], 1'b1, state + 8'b1};
                64:  {twi_sda, twi_scl, state} <= {rom_data[17], 1'b1, state + 8'b1};
                // rom_data[16]
                65:  {twi_sda, twi_scl, state} <= {rom_data[17], 1'b0, state + 8'b1};
                66:  {twi_sda, twi_scl, state} <= {rom_data[16], 1'b0, state + 8'b1};
                67:  {twi_sda, twi_scl, state} <= {rom_data[16], 1'b1, state + 8'b1};
                68:  {twi_sda, twi_scl, state} <= {rom_data[16], 1'b1, state + 8'b1};
                // Ack
                69:  {twi_sda, twi_scl, state} <= {1'b1, 1'b0, state + 8'b1};
                70:  {twi_sda, twi_scl, state} <= {1'b1, 1'b0, state + 8'b1};
                71:  {twi_sda, twi_scl, state} <= {1'b1, 1'b1, state + 8'b1};
                72:  {twi_sda, twi_scl, ack, state} <= {1'b1, 1'b1, sda, state + 8'b1};
                // rom_data[15]
                73:  {twi_sda, twi_scl, state} <= {1'b1, 1'b0, state + 8'b1};
                74:  {twi_sda, twi_scl, state} <= {rom_data[15], 1'b0, state + 8'b1};
                75:  {twi_sda, twi_scl, state} <= {rom_data[15], 1'b1, state + 8'b1};
                76:  {twi_sda, twi_scl, state} <= {rom_data[15], 1'b1, state + 8'b1};
                // rom_data[14]
                77:  {twi_sda, twi_scl, state} <= {rom_data[15], 1'b0, state + 8'b1};
                78:  {twi_sda, twi_scl, state} <= {rom_data[14], 1'b0, state + 8'b1};
                79:  {twi_sda, twi_scl, state} <= {rom_data[14], 1'b1, state + 8'b1};
                80:  {twi_sda, twi_scl, state} <= {rom_data[14], 1'b1, state + 8'b1};
                // rom_data[13]
                81:  {twi_sda, twi_scl, state} <= {rom_data[14], 1'b0, state + 8'b1};
                82:  {twi_sda, twi_scl, state} <= {rom_data[13], 1'b0, state + 8'b1};
                83:  {twi_sda, twi_scl, state} <= {rom_data[13], 1'b1, state + 8'b1};
                84:  {twi_sda, twi_scl, state} <= {rom_data[13], 1'b1, state + 8'b1};
                // rom_data[12]
                85:  {twi_sda, twi_scl, state} <= {rom_data[13], 1'b0, state + 8'b1};
                86:  {twi_sda, twi_scl, state} <= {rom_data[12], 1'b0, state + 8'b1};
                87:  {twi_sda, twi_scl, state} <= {rom_data[12], 1'b1, state + 8'b1};
                88:  {twi_sda, twi_scl, state} <= {rom_data[12], 1'b1, state + 8'b1};
                // rom_data[11]
                89:  {twi_sda, twi_scl, state} <= {rom_data[12], 1'b0, state + 8'b1};
                90:  {twi_sda, twi_scl, state} <= {rom_data[11], 1'b0, state + 8'b1};
                91:  {twi_sda, twi_scl, state} <= {rom_data[11], 1'b1, state + 8'b1};
                92:  {twi_sda, twi_scl, state} <= {rom_data[11], 1'b1, state + 8'b1};
                // rom_data[10]
                93:  {twi_sda, twi_scl, state} <= {rom_data[11], 1'b0, state + 8'b1};
                94:  {twi_sda, twi_scl, state} <= {rom_data[10], 1'b0, state + 8'b1};
                95:  {twi_sda, twi_scl, state} <= {rom_data[10], 1'b1, state + 8'b1};
                96:  {twi_sda, twi_scl, state} <= {rom_data[10], 1'b1, state + 8'b1};
                // rom_data[9]
                97:  {twi_sda, twi_scl, state} <= {rom_data[10], 1'b0, state + 8'b1};
                98:  {twi_sda, twi_scl, state} <= {rom_data[9], 1'b0, state + 8'b1};
                99:  {twi_sda, twi_scl, state} <= {rom_data[9], 1'b1, state + 8'b1};
                100: {twi_sda, twi_scl, state} <= {rom_data[9], 1'b1, state + 8'b1};
                // rom_data[8]
                101: {twi_sda, twi_scl, state} <= {rom_data[9], 1'b0, state + 8'b1};
                102: {twi_sda, twi_scl, state} <= {rom_data[8], 1'b0, state + 8'b1};
                103: {twi_sda, twi_scl, state} <= {rom_data[8], 1'b1, state + 8'b1};
                104: {twi_sda, twi_scl, state} <= {rom_data[8], 1'b1, state + 8'b1};
                // Ack
                105: {twi_sda, twi_scl, state} <= {1'b1, 1'b0, state + 8'b1};
                106: {twi_sda, twi_scl, state} <= {1'b1, 1'b0, state + 8'b1};
                107: {twi_sda, twi_scl, state} <= {1'b1, 1'b1, state + 8'b1};
                108: {twi_sda, twi_scl, ack, state} <= {1'b1, 1'b1, sda, state + 8'b1};
                // rom_data[7]
                109: {twi_sda, twi_scl, state} <= {1'b1, 1'b0, state + 8'b1};
                110: {twi_sda, twi_scl, state} <= {rom_data[7], 1'b0, state + 8'b1};
                111: {twi_sda, twi_scl, state} <= {rom_data[7], 1'b1, state + 8'b1};
                112: {twi_sda, twi_scl, state} <= {rom_data[7], 1'b1, state + 8'b1};
                // rom_data[6]
                113: {twi_sda, twi_scl, state} <= {rom_data[7], 1'b0, state + 8'b1};
                114: {twi_sda, twi_scl, state} <= {rom_data[6], 1'b0, state + 8'b1};
                115: {twi_sda, twi_scl, state} <= {rom_data[6], 1'b1, state + 8'b1};
                116: {twi_sda, twi_scl, state} <= {rom_data[6], 1'b1, state + 8'b1};
                // rom_data[5]
                117: {twi_sda, twi_scl, state} <= {rom_data[6], 1'b0, state + 8'b1};
                118: {twi_sda, twi_scl, state} <= {rom_data[5], 1'b0, state + 8'b1};
                119: {twi_sda, twi_scl, state} <= {rom_data[5], 1'b1, state + 8'b1};
                120: {twi_sda, twi_scl, state} <= {rom_data[5], 1'b1, state + 8'b1};
                // rom_data[4]
                121: {twi_sda, twi_scl, state} <= {rom_data[5], 1'b0, state + 8'b1};
                122: {twi_sda, twi_scl, state} <= {rom_data[4], 1'b0, state + 8'b1};
                123: {twi_sda, twi_scl, state} <= {rom_data[4], 1'b1, state + 8'b1};
                124: {twi_sda, twi_scl, state} <= {rom_data[4], 1'b1, state + 8'b1};
                // rom_data[3]
                125: {twi_sda, twi_scl, state} <= {rom_data[4], 1'b0, state + 8'b1};
                126: {twi_sda, twi_scl, state} <= {rom_data[3], 1'b0, state + 8'b1};
                127: {twi_sda, twi_scl, state} <= {rom_data[3], 1'b1, state + 8'b1};
                128: {twi_sda, twi_scl, state} <= {rom_data[3], 1'b1, state + 8'b1};
                // rom_data[2]
                129: {twi_sda, twi_scl, state} <= {rom_data[3], 1'b0, state + 8'b1};
                130: {twi_sda, twi_scl, state} <= {rom_data[2], 1'b0, state + 8'b1};
                131: {twi_sda, twi_scl, state} <= {rom_data[2], 1'b1, state + 8'b1};
                132: {twi_sda, twi_scl, state} <= {rom_data[2], 1'b1, state + 8'b1};
                // rom_data[1]
                133: {twi_sda, twi_scl, state} <= {rom_data[2], 1'b0, state + 8'b1};
                134: {twi_sda, twi_scl, state} <= {rom_data[1], 1'b0, state + 8'b1};
                135: {twi_sda, twi_scl, state} <= {rom_data[1], 1'b1, state + 8'b1};
                136: {twi_sda, twi_scl, state} <= {rom_data[1], 1'b1, state + 8'b1};
                // rom_data[0]
                137: {twi_sda, twi_scl, state} <= {rom_data[1], 1'b0, state + 8'b1};
                138: {twi_sda, twi_scl, state} <= {rom_data[0], 1'b0, state + 8'b1};
                139: {twi_sda, twi_scl, state} <= {rom_data[0], 1'b1, state + 8'b1};
                140: {twi_sda, twi_scl, state} <= {rom_data[0], 1'b1, state + 8'b1};
                // Ack
                141: {twi_sda, twi_scl, state} <= {1'b1, 1'b0, state + 8'b1};
                142: {twi_sda, twi_scl, state} <= {1'b1, 1'b0, state + 8'b1};
                143: {twi_sda, twi_scl, state} <= {1'b1, 1'b1, state + 8'b1};
                144: {twi_sda, twi_scl, ack, state} <= {1'b1, 1'b1, sda, state + 8'b1};
                // Repeated Start
                145: {twi_sda, twi_scl, state} <= {1'b1, 1'b0, state + 8'b1};
                146: {twi_sda, twi_scl, state} <= {1'b1, 1'b0, state + 8'b1};
                147: begin
                    twi_sda <= 1;
                    twi_scl <= 1;

                    if (&rom_data) begin
                        done <= 1;
                    end else begin
                        rom_addr <= rom_addr + 9'b1;
                    end

                    state <= 0;
                end
                default: {twi_sda, twi_scl, state} <= {1'b1, 1'b1, state};
            endcase
        end
    end

    assign sda = twi_sda ? 1'bz : 1'b0;
    assign scl = twi_scl ? 1'bz : 1'b0;

endmodule : dvp_init
