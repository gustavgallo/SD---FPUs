`timescale 1us/1ps

module tb#();

FPU dut(
     .clock_100Khz(clk),
     .reset(rst), 
     .Op_A_in(send_A),
     .Op_B_in(send_B),
     .data_out(result),
     .status_out(op_status)
);

always begin #5; clk <= ~clk; end // periodo de 10 us, frequencia de 100KHz

initial begin
    // Reset inicial
    rst <= 0;
    clk <= 0;
    #10 rst <= 1;

    // Teste 1: Soma 1.5 + 2.25
    send_A = 32'b01000000000000000000000000000000;
    send_B = 32'b01000000100000000000000000000000;
    #50;

    // Teste 2: Subtração 5.75 - 1.25
    send_A = 32'b01000001010000000000000000000000;
    send_B = 32'b01000000001000000000000000000000;
    #50;

    // Teste 3: Soma com zero (3.0 + 0.0)
    send_A = 32'b01000000110000000000000000000000;
    send_B = 32'b00000000000000000000000000000000;
    #50;

    // Teste 4: Subtração com zero (-2.0 + 0.0)
    send_A = 32'b11000000100000000000000000000000;
    send_B = 32'b00000000000000000000000000000000;
    #50;

    // Teste 5: Overflow simulado (1e10 + 1e10)
    send_A = 32'b01000100010011011001010100011110;
    send_B = 32'b01000100010011011001010100011110;
    #50;

    // Teste 6: Underflow simulado (1e-10 + 1e-10)
    send_A = 32'b00111011011100110101100100111111;
    send_B = 32'b00111011011100110101100100111111;
    #50;

    // Teste 7: Cancelamento total (8.0 + -8.0)
    send_A = 32'b01000001100000000000000000000000;
    send_B = 32'b11000001100000000000000000000000;
    #50;

    // Teste 8: Soma de iguais (4.5 + 4.5)
    send_A = 32'b01000001000100000000000000000000;
    send_B = 32'b01000001000100000000000000000000;
    #50;

    // Teste 9: Subtração parcial (7.0 + -3.0)
    send_A = 32'b01000001011100000000000000000000;
    send_B = 32'b11000000110000000000000000000000;
    #50;

    // Teste 10: Diferença de expoentes grande (1024.0 + 1.0)
    send_A = 32'b01000110000000000000000000000000;
    send_B = 32'b01000000000000000000000000000000;
    #50;

    $finish;
end

endmodule