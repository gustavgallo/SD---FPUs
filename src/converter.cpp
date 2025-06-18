#include <iostream>
#include <cmath>
#include <cstdint>
#include <bitset>

uint32_t floatToCustom(float value) {
    // Tratar zero como caso especial
    if (value == 0.0f)
        return 0;

    uint32_t result = 0;

    // Pegar sinal
    uint32_t sign = std::signbit(value) ? 1 : 0;

    // Valor absoluto
    float absVal = std::fabs(value);

    // Extrair expoente e mantissa normalizada
    int exp;
    float norm = std::frexp(absVal, &exp); // norm ∈ [0.5, 1.0)
    
    // Converter expoente para bias-511 (10 bits)
    int biasedExp = exp + 510; // Bias 511
    if (biasedExp < 0 || biasedExp > 1023) {
        std::cerr << "Erro: expoente fora do intervalo de 10 bits!" << std::endl;
        return 0;
    }

    // Calcular mantissa de 21 bits (sem o bit implícito)
    float mantissa = (norm * 2.0f) - 1.0f; // agora ∈ [0.0, 1.0)
    uint32_t mantBits = static_cast<uint32_t>(mantissa * (1 << 21));

    // Montar o número final
    result = (sign << 31) | (biasedExp << 21) | (mantBits & 0x1FFFFF);
    return result;
}

// Função utilitária para imprimir como binário
void printCustom(float value) {
    uint32_t encoded = floatToCustom(value);
    std::bitset<32> bits(encoded);
    std::cout << value << " -> " << bits << std::endl;
}

int main() {
    printCustom(2.0f);
    printCustom(1.0f);
    printCustom(5.75f);
    printCustom(1.25f);
    printCustom(3.0f);
    printCustom(0.0f);
    printCustom(-2.0f);
    printCustom(1e10f);
    printCustom(1e-10f);
    printCustom(8.0f);
    printCustom(-8.0f);
    printCustom(4.5f);
    printCustom(7.0f);
    printCustom(-3.0f);
    printCustom(1024.0f);
}
