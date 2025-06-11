// clk de 100Khz

module FPU(
    input logic clock_100Khz;
    input logic reset; // assincrono
    input logic [31:0] Op_A_in;
    input logic [31:0] Op_B_in;
    output logic [31:0] data_out;
    output logic status_out;
);

typedef enum logic { 
    DECODE,
    OPERATION
} state;

state EA;
logic [31:0] aux_A;
logic [31:0] aux_B;
logic [9:0] ;

// faz expoente comb

always @(posedge clock_100Khz, negedge reset) begin
    if(!reset) begin

    end
    
    case(EA) 
        DECODE: begin
            if(Op_A_in[31]) begin
                aux_A <= -1 * ({1, Op_A_in[20, 0]}) << 

            end else begin

            end
        end

    endcase
end

//(-1)s × (1 + fração) × 2(Expoente – BIAS)

//X = 10
//Y = 21
//BIAS = 

endmodule