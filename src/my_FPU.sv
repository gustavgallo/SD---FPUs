// clk de 100Khz

typedef enum logic[3:0]{
    DECODE,
    ALIGN,
    OPERATE,
    NORMALIZE,
    WRITEBACK
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

state_t EA, PE;
logic sign_A, sign_B, sign_OUT, carry, compare;
logic [21:0] mant_A, mant_B, mant_TMP, mant_OUT;
logic [9:0] exp_A, exp_B, exp_TMP, exp_OUT; // vou ter que ver quantos espaços precisa
logic [9:0] diff_Exponent;
logic [4:0] counter;

always_ff @(posedge clock_100Khz or negedge reset) begin
    if(!reset) begin
        EA <= DECODE;
    end else begin
        case (EA)
            DECODE:begin                    
                 EA <= ALIGN;
            end

            ALIGN:begin     
                EA <= OPERATE;
            end

            OPERATE:begin     
                    EA <= NORMALIZE;
            end

            NORMALIZE: begin
                if (mant_TMP[21] || exp_TMP == 0 || counter == 5'd21)
                    EA <= WRITEBACK;
                else
                    EA <= NORMALIZE;
            end

            WRITEBACK: begin      
                  EA <= DECODE;
            end
            default:    EA <= DECODE;
        endcase
    end
end


always_ff @(posedge clock_100Khz or negedge reset) begin
    if(!reset) begin
            data_out   <= 32'd0;
            status_out <= EXACT;
            mant_TMP   <= 22'd0;
            exp_TMP    <= 10'd0;
            counter <= 5'd0;
    end else begin
        case(EA) 
            DECODE: begin
                compare =  (Op_A_in[30:21] >= Op_B_in[30:21])? 1'b1 : 1'b0; // ve qual é maior ou se são iguais
  
                mant_A <= compare ? {1'b1,Op_A_in[20:0]} : {1'b1,Op_B_in[20:0]}; // armazena mant do maior em A
                exp_A  <= compare ? Op_A_in[30:21] : Op_B_in[30:21];             // exp do maior em A
                sign_A <= compare ? Op_A_in[31] : Op_B_in[31];                   // sinal do maior 

                mant_B <= compare ? {1'b1,Op_B_in[20:0]} : {1'b1,Op_A_in[20:0]};  // armazena mant do outro em B
                exp_B  <= compare ? Op_B_in[30:21] : Op_A_in[30:21];              // exp do outro em B
                sign_B <= compare ? Op_B_in[31] : Op_A_in[31];                    // sinal do outro 

            end
            ALIGN: begin
                diff_Exponent <= exp_A-exp_B; // pega a diferença dos expoentes e coloca mant_A e mant_B na mesma base, B sempre é o menor quando eles são diferentes
                mant_B <= (mant_B >> diff_Exponent); // shift right em mant_B para alinhar
            end
            OPERATE: begin
                if (sign_A == sign_B) begin                     
                        {carry, mant_TMP} <= mant_A + mant_B;   // soma se forem de sinais iguais, pega o bit carry por concatenação
                    end else begin
                        mant_TMP <= mant_A - mant_B;            // subtrai se forem de diferentes
                        carry    <= 1'b0;                       // sub não tem carry nunca
                    end

                    exp_TMP <= exp_A;

                    if (carry) begin                    // arruma o numero caso houver carry
                        mant_TMP <= (mant_TMP >> 1);
                        exp_TMP  <= exp_TMP + 1;
                    end
                    counter <= 5'd0;

            end
            NORMALIZE: begin

                $display("mant_TMP=%b exp_TMP=%0d counter=%0d", mant_TMP, exp_TMP, counter);
                if (!mant_TMP[21] && exp_TMP > 0 && counter < 21) begin   // normaliza o resultado
                        mant_TMP <= mant_TMP << 1;
                        exp_TMP  <= exp_TMP - 1;
                        counter <= counter + 1;
                    end
            end
            WRITEBACK: begin
                sign_OUT  <= sign_A;
                    mant_OUT  <= mant_TMP[20:0];
                    exp_OUT   <= exp_TMP;
                    data_out  <= {sign_OUT, exp_OUT, mant_OUT};

                    if (exp_OUT == 10'd0)
                        status_out <= UNDERFLOW;
                    else if (exp_OUT == 10'd1023)
                        status_out <= OVERFLOW;
                    else if (|mant_TMP[0])
                        status_out <= INEXACT;
                    else
                        status_out <= EXACT;
            end
        endcase
    end
end
endmodule