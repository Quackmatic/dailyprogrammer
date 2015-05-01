#include <stdio.h>

int main(int argc, char * argv[]) {
	double a = 0.0, b;
	for(b = 1; b < 50; b++) {
		a += 50.0 / b / b / b / b / b / b / b / b;
	}
	a *= 189.0;
	for(b = 1; b < 4; b++) {
		double c = a;
		c = (c + a / c) / 2.0;
		a = c;
	}
	printf("%F\n", a);
}
