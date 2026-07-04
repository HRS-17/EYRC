module top_module(
    input clk,
    input in,
    input reset,    // Synchronous reset
    output reg [7:0] out_byte,
    output done
);
    reg [3:0] state, nstate;
    // a:idle | b..i: 8 data bits (LSB..MSB) | j: parity bit | k,l: wait for stop | m: stop received
    parameter a=0,b=1,c=2,d=3,e=4,f=5,g=6,h=7,i=8,j=9,k=10,l=11,m=12;

    always @(*) begin
        case(state)
            a: nstate = in ? a : b;
            k: nstate = in ? m : l;
            l: nstate = in ? a : l;
            m: nstate = in ? a : b;
            default: nstate = state + 1;
        endcase
    end

    always @(posedge clk) begin
        if (reset) state <= a;
        else state <= nstate;
    end

    // Shift in the 8 data bits, LSB first
    always @(posedge clk) begin
        if (state >= b && state <= i)
            out_byte <= {in, out_byte[7:1]};
    end

    // Capture received parity bit and the calculated parity together,
    // right after the 8 data bits have been processed (state j).
    reg parity_rec, parity_cal;
    wire parity_out;

    always @(posedge clk) begin
        if (state == j) begin
            parity_rec <= in;
            parity_cal <= parity_out;
        end
    end

    // Reset the parity calculator *combinationally* on the current state,
    // so it correctly accumulates exactly the 8 data bits (states b..i)
    // with no off-by-one lag.
    wire p_reset = reset || !(state >= b && state <= i);

    parity p_checker(clk, p_reset, in, parity_out);

    // Odd parity: total 1s (data + parity) must be odd, i.e. the XOR of the
    // data bits must differ from the received parity bit.
    assign done = (state == m) && (parity_cal != parity_rec);

endmodule
