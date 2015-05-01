using System;

namespace ComplexExercise
{
    public struct Complex
    {
        public double Real
        {
            get;
            set;
        }

        public double Imaginary
        {
            get;
            set;
        }

        public double Modulus
        {
            get
            {
                return Math.Sqrt(ModulusSquared);
            }
        }

        public double ModulusSquared
        {
            get
            {
                return Real * Real + Imaginary * Imaginary;
            }
        }

        public Complex Conjugate
        {
            get
            {
                return new Complex(Real, -Imaginary);
            }
        }

        public double Argument
        {
            get
            {
                if(Imaginary == 0 && Real == 0)
                {
                    return 0;
                }
                else
                {
                    return Math.Atan2(Imaginary, Real);
                }
            }
        }

        public Complex(double real, double imaginary = 0)
            : this()
        {
            Real = real;
            Imaginary = imaginary;
        }

        public static Complex operator +(Complex a, double b)
        {
            return new Complex(a.Real + b, a.Imaginary);
        }

        public static Complex operator +(Complex a, Complex b)
        {
            return new Complex(a.Real + b.Real, a.Imaginary + b.Imaginary);
        }

        public static Complex operator -(Complex a, Complex b)
        {
            return new Complex(a.Real - b.Real, a.Imaginary - b.Imaginary);
        }

        public static Complex operator -(Complex a, double b)
        {
            return new Complex(a.Real - b, a.Imaginary);
        }

        public static Complex operator *(Complex a, Complex b)
        {
            return new Complex(a.Real * b.Real - a.Imaginary * b.Imaginary, a.Real * b.Imaginary + a.Imaginary * b.Real);
        }

        public static Complex operator *(Complex a, double b)
        {
            return new Complex(a.Real * b, a.Imaginary * b);
        }

        public static Complex operator /(Complex a, Complex b)
        {
            return (a * b.Conjugate) / b.ModulusSquared;
        }

        public static Complex operator /(Complex a, double b)
        {
            return new Complex(a.Real / b, a.Imaginary / b);
        }

        public static bool operator ==(Complex a, Complex b)
        {
            return a.Real == b.Real && a.Imaginary == b.Imaginary;
        }

        public static bool operator !=(Complex a, Complex b)
        {
            return a.Real != b.Real || a.Imaginary != b.Imaginary;
        }

        public static bool operator ==(Complex a, double b)
        {
            return a.Real == b && a.Imaginary == 0;
        }

        public static bool operator !=(Complex a, double b)
        {
            return a.Real != b || a.Imaginary != 0;
        }

        public override string ToString()
        {
            if (Real == 0 && Imaginary == 0)
            {
                return "0";
            }
            else if (Real == 0)
            {
                return String.Format("{0}i", Imaginary);
            }
            else if (Imaginary == 0)
            {
                return String.Format("{0}", Real);
            }
            else
            {
                return String.Format("{0}+{1}i", Real, Imaginary)
                    .Replace("+-", "-");
            }
        }
    }
}