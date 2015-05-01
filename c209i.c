#include <ctype.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

typedef struct {
	int x;
	int y;
} point;

point xy(int x, int y) {
	point p = { x, y };
	return p;
}

point path(int * str, int * grid, int width, int height, int rem, point p) {
	if(rem < 0) 
	str[width * p.y + p.x] = 

point pack(int * str, int * grid, int width, int height, point p) {
	point r;
	do {
		r = path(grid, width, height, width * height, xy(rand() % width, rand() % height));
	} while(r.x < 0);
	return r;
}

int main(int argc, char * argv[]) {
	int temp, input[256] = {0};
	int index = 0, width, height;
	srand(time(NULL));
	while(index < 255 && (temp = fgetc(stdin)) != EOF) {
		if(!isspace(temp)) {
			input[index++] = temp;
		}
	}
	for(width = (int)ceil(sqrt(index)); width > 0 && index % width > 0; width--);
	height = index / width;
	if(height > width) {
		int swap = height;
		height = width;
		width = swap;
	}
	{
		int * grid = malloc(sizeof(int) * index);
		point start = pack(input, grid, width, height);
		printf("%d %d\n", start.x, start.y);
	}
	return 0;
}
