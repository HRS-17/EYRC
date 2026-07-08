
// alu.v - ALU module

module alu #(parameter WIDTH = 32) (
    input       [WIDTH-1:0] a, b,       // operands
    input		 [1:0] ALUOp,
	 input 		 [2:0] func3,
	 input       funct7b5,
	 input		 opb5,
    output reg  [WIDTH-1:0] alu_out,    // ALU output
    output      zero                    // zero flag
);


/*
always @(a, b, alu_ctrl) begin
    case (alu_ctrl)
        3'b000:  alu_out <= a + b;       // ADD
        3'b001:  alu_out <= a + ~b + 1;  // SUB
        3'b010:  alu_out <= a & b;       // AND
        3'b011:  alu_out <= a | b;       // OR
        3'b101:  begin                   // SLT
                     if (a[31] != b[31]) alu_out <= a[31] ? 0 : 1;
                     else alu_out <= a < b ? 1 : 0;
                 end
        default: alu_out = 0;
    endcase
end

assign zero = (alu_out == 0) ? 1'b1 : 1'b0;

endmodule
*/

always @(*) begin
    case (ALUOp)
        2'b00: alu_out <= a + b;             // addition
        2'b01: alu_out <= a + ~b + 1;//ALUControl = 4'b0001;             // subtraction
        default:
            case (func3) // R-type or I-type ALU
                3'b000: begin
                    // True for R-type subtract
                    if   (funct7b5 & opb5) alu_out <= a + ~b + 1;//ALUControl = 4'b0001; //sub
                    else alu_out <= a + b;//ALUControl = 4'b0000; // add, addi
                end
                3'b001:  alu_out<= a*(2**(b[4:0]));//ALUControl = 4'b0110; //sll,slli
                3'b010:  begin                   // SLT
                            if (a[31] != b[31]) alu_out <= a[31] ? 1 : 0; //0:1 changed to 
                            else alu_out <= a < b ? 1 : 0;
                        end//ALUControl = 4'b0101; // slt, slti
                3'b011:  alu_out <= a < b ? 1 : 0;//ALUControl = 4'b0111; //sltu,sltiu
                3'b100:  alu_out <= a ^ b; //ALUControl = 4'b0100; //xor,xori
                3'b101:  case(funct7b5)
                            1'b0:alu_out <= a >> b[4:0];//ALUControl = 4'b1000; //srli,srl
                            1'b1:alu_out <= $signed(a)>>>b[4:0];//ALUControl = 4'b1001; //sra,srai
                            
                         endcase
                3'b110:  alu_out <= a | b;//ALUControl = 4'b0011; // or, ori
                3'b111:  alu_out <= a & b;//ALUControl = 4'b0010; // and, andi
                
                //default: ALUControl = 4'bxxxx; // ???
            endcase
    endcase
end

assign zero = (alu_out == 0) ? 1'b1 : 1'b0;

endmodule
