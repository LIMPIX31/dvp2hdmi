module edge_detector (
    input logic clk,

    input logic signal,

    output logic front
);

    logic signal_reg;

    always_ff @(posedge clk) begin
        signal_reg <= signal;
    end

    assign front = signal_reg ^ signal;

endmodule : edge_detector
