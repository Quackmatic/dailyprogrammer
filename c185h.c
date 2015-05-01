#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define PR "%.12lg\n"

/* creates a new polynomial with the given degree */
double * polynomial_new(int degree)
{
    double * terms = malloc(sizeof(double) * (degree + 1));
    int i;
    for(i = 0; i <= degree; i++)
    {
        terms[i] = 0;
    }
    return terms;
}

/* inputs the polynomial */
double * polynomial_input(int * out_degree)
{
    char * input_string = NULL, * ois, input_state = 0, degree;
    size_t sz;
    double * polynomial = NULL, multiplier = 1;

    getline(&input_string, &sz, stdin);
    ois = input_string;

    while(*input_string != '\n')
    {
        if(!input_state) /* coefficient */
        {
            if(*input_string == 'x')
            {
                input_state++;
                continue;
            }
            else if(*input_string == '-') input_string++, multiplier = -1.;
            else if(*input_string == '+') input_string++, multiplier = 1.;
            else
            {
                multiplier *= strtod(input_string, &input_string);
                input_state++;
            }
        }
        else
        {
            int exponent = 1;
            input_string++;
            if(*input_string == '^')
            {
                exponent = strtol(++input_string, &input_string, 10);
            }
            if(!polynomial) polynomial = polynomial_new(degree = exponent);
            polynomial[exponent] = multiplier;
            input_state ^= input_state;
            multiplier = 0;
        }
    }
    if(multiplier != 0) polynomial[0] = multiplier;
    *out_degree = degree;
    free(ois);
    return polynomial;
}

/* computes the value of the nth derivative of the polynomial for given x */
double polynomial_eval(double x, double * polynomial, int degree, int n)
{
    double result = 0, a;
    int i, j, k;
    for(i = n; i <= degree; i++)
    {
        a = polynomial[i];
        j = i;
        k = n;
        while(k-->0)
        {
            a *= j;
            j--;
        }
        if(j < 2)
        {
            result += polynomial[i] * (j ? x : 1);
        }
        else
        {
            while(j-->0)
            {
                a *= x;
            }
            result += a;
        }
    }
    return result;
}

/* uses Halley's method to find one root of the polynomial */
double polynomial_findroot(double starting_point, double * polynomial, int degree)
{
    double last_starting_point = 0;
    double x, dx, ddx;
    int attempts = 0;
    while(attempts++ < 1<<24)
    {
        last_starting_point = starting_point;
        x = polynomial_eval(starting_point, polynomial, degree, 0);
        dx = polynomial_eval(starting_point, polynomial, degree, 1);
        ddx = polynomial_eval(starting_point, polynomial, degree, 2);
        starting_point = starting_point -
            (2. * x * dx) / (2. * dx * dx - x * ddx);
        x = starting_point - last_starting_point;
        if(x < 0) x = -x;
        if(x < 1e-12) return starting_point;
    }
    return 0./0.;
}

double * polynomial_div_term(double * polynomial, int degree, double divisor)
{
    double * new_polynomial = polynomial_new(degree - 1), acc = polynomial[degree];
    int i;
    for(i = degree - 1; i >= 0; i--)
    {
        new_polynomial[i] = acc;
        acc = polynomial[i] - divisor * acc;
    }
    free(polynomial);
    return new_polynomial;
}

int main(int argc, char * argv[])
{
    int deg;
    double * pol = polynomial_input(&deg);
    double root = -4;
    while(1)
    {
        if(deg == 1)
        {
            if(pol[0] == 0) break;
            printf(PR, -pol[1] / pol[0]);
            break;
        }
        else if(deg == 2)
        {
            double dis = sqrt(pol[1] * pol[1] - 4 * pol[2] * pol[0]);
            if(dis != dis) break;
            printf(PR, (-pol[1] + dis) / (2 * pol[2]));
            printf(PR, (-pol[1] - dis) / (2 * pol[2]));
            break;
        }
        else
        {
            root = polynomial_findroot(root, pol, deg);
            if(root != root)
            {
                break;
            }
            printf(PR, root);
            pol = polynomial_div_term(pol, deg--, -root);
        }
    }
    printf("No more roots.\n");
    free(pol);
    return 0;
}