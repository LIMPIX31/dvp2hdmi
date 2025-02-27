// Copyright (c) 2025 Sigma Logic

// lvds_pkg.sv
package lvds_pkg;

    typedef struct packed {
        logic p;
        logic n;
    } pair_t;

endpackage : lvds_pkg

// lvds_out.sv
module lvds_out
    import lvds_pkg::pair_t;
#(
    parameter string Mode = "True"
) (
    input logic single,

    output pair_t pair
);

    generate
        if (Mode == "True") begin : gen_true_lvds_out
            TLVDS_OBUF u_true_lvds_obuf (
                .I (single),
                .O (pair.p),
                .OB(pair.n)
            );
        end else begin : gen_emulated_lvds_out
            ELVDS_OBUF u_emulated_lvds_obuf (
                .I (single),
                .O (pair.p),
                .OB(pair.n)
            );
        end
    endgenerate

endmodule : lvds_out
