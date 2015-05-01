/*
reddit.com/r/DailyProgrammer
Solution to Challenge #131: Who Tests the Tests?
*/

#include <stdio.h>
#include <string.h>
#define UPPER(X) ((X) >= 97 && (X) <= 122 ? (X) - 32 : (X))
#define BUFFER_LENGTH 1024

int line_count = 0, expected_line_count = 0;

void handle_line(char *c, int len);

int main(int argc, char **argv)
{
	FILE *f; int len = 0, line_len = 0; char a, buf[BUFFER_LENGTH] = {0}; // vulnerable to buffer overflows if the line is too long
	if(argc < 2) return;
	f = fopen(argv[1], "r");
	while((a = fgetc(f)) != EOF)
	{
		buf[line_len++, len++] = a;
		if(a == '\n')
			handle_line(buf + (len - line_len), line_len), line_len = 0;
	}
	fclose(f);
	return 0;
}

void handle_line(char *c, int len)
{
	char pt1[BUFFER_LENGTH] = {0}, pt2[BUFFER_LENGTH] = {0}; // again vulnerable to buffer overflows
	int mode, i, part_len;
	c[len] = 0; // sets the /n at the end of the line to a null to stop sscanf overrunning the line
	if(line_count == 0)
	{
		sscanf(c, "%d", &expected_line_count); // set remaining line count
		expected_line_count += 1; // this is to make up for the fact that it will be decremented at the end of the function call
		printf("Expected line count: %d\n", expected_line_count);
	}
	else
	{
		if(expected_line_count <= 0) // check lines hasn't exceeded that given in the first line
		{
			printf("Warning on %d: exceeded the expected line count, skipping\n", line_count);
			goto end_func;
		}
		sscanf(c, "%d %s %s", &mode, pt1, pt2);
		if((part_len = strlen(pt1)) != strlen(pt2))
		{
			printf("Bad data at line %d: different lengths\n", line_count);
			goto end_func;
		}
		if(mode == 0) // reverse check
		{
			for(i = 0; i < part_len; i++)
			{
				if(pt1[(part_len - 1) - i] != pt2[i])
				{
					printf("Bad data at line %d: not reversed correctly\n", line_count);
					goto end_func;
				}
			}
		}
		else if(mode == 1) // capitalization check
		{
			for(i = 0; i < part_len; i++)
			{
				if(UPPER(pt1[i]) != pt2[i])
				{
					printf("Bad data at line %d: not capitalised correctly\n", line_count);
					goto end_func;
				}
			}
		}
		printf("Good data at line %d\n", line_count);
	}
	end_func:
	expected_line_count--;
	line_count++;
}