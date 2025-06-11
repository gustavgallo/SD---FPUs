#include <iostream>
using namespace std;

int main(){
    int x = 8 + (2+4+1+0+6+7+0+7+3)%4;
    int y = 31 - x;

    cout << x << endl << y << endl;

    return 0;
}
