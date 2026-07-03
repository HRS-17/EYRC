module top_module(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
    input ground,
    input dig,
    output walk_left,
    output walk_right,
    output aaah,
    output digging ); 

    
    reg [2:0] state,nstate;
    parameter left=3'd0,right=3'd1,fleft=3'd2,fright=3'd3,dleft=3'd4,dright=3'd5,splat=3'd6,calm=3'd7;
    
    //mod 20 counter 
    wire [4:0]count_out;
    wire count_clear;
    assign count_clear = areset || (state!=fleft&& state!=fright);
    counter count (clk,count_clear,count_out,state);
    // comb logic
    always @(*) begin
        case(state)
            left:begin
                if (~ground) nstate=fleft;
                else if (dig) nstate=dleft;
                else if(bump_left) nstate=right;
                else nstate=left;
            end
            right:begin
                if (~ground) nstate=fright;
                else if (dig) nstate=dright;
                else if(bump_right) nstate=left;
                else nstate=right;
            end
            fleft:begin
                if (~ground) begin
                    if (count_out>5'd18) nstate=splat;
                    else nstate=fleft; 	
                end
                else
                    nstate = left;
            end
            fright:begin
                if (~ground) begin
                    if (count_out>5'd18) nstate=splat;
                    else nstate=fright;
                end
                else nstate = right;
            end
            dleft:begin
                if (~ground) nstate=fleft;
                else  nstate=dleft; 
            end
            dright:begin
                if (~ground) nstate=fright;
                else nstate=dright;
            end
            splat:begin
                if (~ground)nstate=splat;
                else nstate=calm;
            end
                
            default:nstate=state;
        endcase
    end
    
    // state transition logic
    always @(posedge clk,posedge areset) begin
        if (areset) state<= left;
        else state<=nstate;
    end
    
    // output logic
    always @(*) begin
        case (state)
            left:{walk_left,walk_right,aaah,digging}=4'b1000;
            right:{walk_left,walk_right,aaah,digging}=4'b0100;
            fleft:{walk_left,walk_right,aaah,digging}=4'b0010;
            fright:{walk_left,walk_right,aaah,digging}=4'b0010;
            dleft:{walk_left,walk_right,aaah,digging}=4'b0001;
            dright:{walk_left,walk_right,aaah,digging}=4'b0001;
            splat:{walk_left,walk_right,aaah,digging}=4'b0010;
            calm:{walk_left,walk_right,aaah,digging}=4'b0000;
        endcase
    end

endmodule

module counter (input clk,input reset,output reg [4:0] q ,input[2:0] state);
    always @(posedge clk) begin
        if (reset) q <= 5'd0;
        else begin
            q <= q + 1'b1;   
        end
    end
endmodule
