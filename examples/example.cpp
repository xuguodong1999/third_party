#include <iostream>

int main(int argc, char **argv) {
    int a = 0x04000000;
    int b = 0x5a;
    std::cout << a + b << "," << (a | b) << std::endl;
    return 0;
}