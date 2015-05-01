/*
reddit.com/r/DailyProgrammer
Solution to Challenge #130: Roll the Dies
*/

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(int argc, char **argv)
{
	int rolls, faces;
	srand(time(NULL));
	while(scanf("%dd%d", &rolls, &faces))
	{
		while(rolls--) printf("%d ", rand() % faces + 1);
		puts("");
	}
}