/*
Create a set of counters suitable for use as a 12-hour clock (with am/pm indicator). 
Your counters are clocked by a fast-running clk, with a pulse on ena whenever your clock should increment (i.e., once per second).

reset resets the clock to 12:00 AM. pm is 0 for AM and 1 for PM. hh, mm, and ss are two BCD (Binary-Coded Decimal) digits each for 
hours (01-12), minutes (00-59), and seconds (00-59). Reset has higher priority than enable, and can occur even when not enabled.
*/


module top_module(
    input clk,
    input reset,
    input ena,
    output pm,
    output [7:0] hh,
    output [7:0] mm,
    output [7:0] ss); 
    
    // seconds hand
    wire en_s_high;
    assign en_s_high = (ss[3:0]==4'd9)&ena;
    bcd_count_10 s_low  (clk,reset,ena,ss[3:0]);
    bcd_count_6  s_high (clk,reset,en_s_high,ss[7:4]);
    // minutes hand
    wire en_m_high,en_m_low;
    assign en_m_low = (ss[7:0]==8'h59)&ena;
    assign en_m_high = ((mm[3:0]==4'd9)&(ss[7:0]==8'h59)&ena);
    bcd_count_10 m_low  (clk,reset,en_m_low,mm[3:0]);
    bcd_count_6  m_high (clk,reset,en_m_high,mm[7:4]);
    // hours hand
    wire en_h;
    assign en_h = ((mm[7:0]==8'h59)&(ss[7:0]==8'h59)&ena);
    bcd_h hours_both  (clk,reset,en_h,pm,hh);

    

endmodule

module bcd_count_10 (input clk,input reset,input enable,output [3:0] q);
    always @(posedge clk) begin
        if (reset)
            q<=4'b0;
        else if (enable) 
            case (q)
                4'd0:q<=4'd1;
                4'd1:q<=4'd2;
                4'd2:q<=4'd3;
                4'd3:q<=4'd4;
                4'd4:q<=4'd5;
                4'd5:q<=4'd6;
                4'd6:q<=4'd7;
                4'd7:q<=4'd8;
                4'd8:q<=4'd9;
                4'd9:q<=4'd0;
                default:q<=q;
            endcase
        else
            q<=q;
    end
endmodule
module bcd_count_6 (input clk,input reset,input enable,output [3:0] q);
    always @(posedge clk) begin
        if (reset)
            q<=4'b0;
        else if (enable) 
            case (q)
                4'd0:q<=4'd1;
                4'd1:q<=4'd2;
                4'd2:q<=4'd3;
                4'd3:q<=4'd4;
                4'd4:q<=4'd5;
                4'd5:q<=4'd0;
                default:q<=q;
            endcase
        else
            q<=q;
    end
endmodule
module bcd_h (input clk,input reset,input enable,output pm,output [7:0] q);
    always @(posedge clk) begin
      
        if (reset)
            q<=8'h12;
        else if (enable) 
            case (q)
                8'h01:q<=8'h02;
                8'h02:q<=8'h03;
                8'h03:q<=8'h04;
                8'h04:q<=8'h05;
                8'h05:q<=8'h06;
                8'h06:q<=8'h07;
                8'h07:q<=8'h08;
                8'h08:q<=8'h09;
                8'h09:q<=8'h10;
                8'h10:q<=8'h11;
                8'h11:begin
                    q<=8'h12;
                    pm<=~pm;
                end
                8'h12:q<=8'h01;
                default:q<=q;
            endcase
        else
            q<=q;
        
    end
endmodule
/*
module bcd_h_high (input clk,input reset,input enable,input,[7:0]ss,input,[7:0]mm,input pm,output [7:0] q,output am);
    always @(posedge clk) begin
        if (reset)
            q<=4'b0;
        else if (enable) 
            case (q)
                4'd0:q[7:4]<=4'd1;
                4'd1:
                    q[7:4]<=4'd2;
                	am<= ((ss==8'h59)&(mm==8'h59)&(q[3:0]==4'd1))? pm:~pm;
                4'd2:
                    q<=4'd1;
                	am<= ()? pm:~pm;
                default:q<=q;
            endcase
        else
            q<=q;
    end
endmodule
*/
