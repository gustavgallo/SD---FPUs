// clk de 100Khz

typedef enum logic { 
    DECODE,
    OPERATION
} state_t;

typedef enum logic[3:0] { 
    OVERFLOW,
    UNDERFLOW,
    EXACT,
    INEXACT
} status_t;

module FPU(
    input logic clock_100Khz,
    input logic reset, // assincrono
    input logic [31:0] Op_A_in,
    input logic [31:0] Op_B_in,
    output logic [31:0] data_out,
    output status_t status_out
);

state_t EA;
logic signalA, signalB;
logic [31:0] mant_A;
logic [31:0] mant_B;
logic [9:0] expA; // vou ter que ver quantos espaços precisa
logic [9:0] expB;
logic [9:0] auxExpNorm;
logic start;

// faz expoente comb

always_comb begin 

    if(start) begin
        expA = Op_A_in[30:21] - 10'd511; // conferir se ta certo
        expB = Op_B_in[30:21] - 10'd511;

        auxExpNorm = (expA>expB)? expA-expB:expB-expA;    

        mant_A = {1'b1, Op_A_in[20:0]};
        mant_B = {1'b1, Op_A_in[20:0]};
    end 

end

always @(posedge clock_100Khz, negedge reset) begin
    if(!reset) begin
        
    end

    if(auxExpNorm) begin
        if(expA>expB) begin
            mant_B <= mant_B >> auxExpNorm;
        end else (if(expB > expA)) begin
            mant_A <= mant_A >> auxExpNorm;
        end
    end
end

// confere sinal, faz o calculo dos expoentes (comb), confere qual expoente é maior, faz Z shifts para deixar as mantissas com a mesma base, soma as mantissas de mesma base

//(-1)s × (1 + fração) × 2(Expoente – BIAS)

//X = 10
//Y = 21
//BIAS = 2^(9) - 1 = 511

endmodule