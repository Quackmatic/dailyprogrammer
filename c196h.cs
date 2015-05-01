using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Challenge196Hard
{
    class Program
    {
        static List<Operator> GetOperators()
        {
            List<Operator> operators = new List<Operator>();

            int operatorCount = Int32.Parse(Console.ReadLine());
            for (int i = 0; i < operatorCount; i++)
            {
                operators.Add(Operator.FromInput(Console.ReadLine()));
            }

            return operators;
        }

        static List<Token> TokenizeInput(List<Operator> operators)
        {
            char[] numeric = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' };

            string input = Console.ReadLine();
            List<Token> tokens = new List<Token>();

            while (input.Length > 0)
            {
                if (input[0] == ' ')
                {
                    input = input.Substring(1);
                }
                else if (Array.IndexOf(numeric, input[0]) != -1)
                {
                    int number = 0, index;
                    while (input.Length > 0 && (index = Array.IndexOf(numeric, input[0])) != -1)
                    {
                        number = number * 10 + index;
                        input = input.Substring(1);
                    }
                    tokens.Add(new IntegerToken { Value = number });
                }
                else if (input.StartsWith("("))
                {
                    input = input.Substring(1);
                    tokens.Add(new BracketToken { Type = BracketToken.BracketType.Left });
                }
                else if (input.StartsWith(")"))
                {
                    input = input.Substring(1);
                    tokens.Add(new BracketToken { Type = BracketToken.BracketType.Right });
                }
                else
                {
                    foreach (Operator op in operators.OrderByDescending(o => o.Symbol.Length))
                    {
                        if (input.StartsWith(op.Symbol))
                        {
                            input = input.Substring(op.Symbol.Length);
                            tokens.Add(new OperatorToken { Operator = op });
                            goto SkipThrow;
                        }
                    }
                    throw new Exception("Invalid symbol near " + input.Substring(0, 10));
                SkipThrow: ;
                }
            }

            return tokens;
        }

        static string Parse(Queue<Token> tokens, List<Operator> operators, Queue<Operator> waiting)
        {
            if (tokens.Count == 0)
                throw new Exception("End of line reached.");

            if (waiting.Count == 0)
            {
                if (tokens.Peek() is IntegerToken)
                {
                    IntegerToken integerToken = tokens.Dequeue() as IntegerToken;
                    return integerToken.Value.ToString();
                }
                else if (tokens.Peek() is BracketToken)
                {
                    BracketToken bracketToken = tokens.Dequeue() as BracketToken;
                    if (bracketToken.Type != BracketToken.BracketType.Left)
                        throw new Exception("Mismatched bracket.");
                    string value = Parse(tokens, operators, new Queue<Operator>(operators));
                    bracketToken = tokens.Dequeue() as BracketToken;
                    if (bracketToken == null || bracketToken.Type != BracketToken.BracketType.Right)
                        throw new Exception("Mismatched bracket.");
                    return value;
                }
                else
                {
                    throw new Exception("Bad input.");
                }
            }
            else
            {
                Operator op = waiting.Dequeue();

                if (op.Associativity == Associativity.Left)
                {
                    string subtree = Parse(tokens, operators, new Queue<Operator>(waiting));
                    OperatorToken token;
                    while (tokens.Count > 0 && (token = tokens.Peek() as OperatorToken) != null && token.Operator.Symbol == op.Symbol)
                    {
                        tokens.Dequeue();
                        subtree = String.Format("({0}{2}{1})",
                            subtree,
                        Parse(tokens, operators, new Queue<Operator>(waiting)),
                        op.Symbol);
                    }
                    return subtree;
                }
                else
                {
                    Stack<string> subtrees = new Stack<string>();
                    subtrees.Push(Parse(tokens, operators, new Queue<Operator>(waiting)));
                    OperatorToken token;
                    while (tokens.Count > 0 && (token = tokens.Peek() as OperatorToken) != null && token.Operator.Symbol == op.Symbol)
                    {
                        tokens.Dequeue();
                        if (token == null || token.Operator.Symbol != op.Symbol)
                            throw new Exception("Unexpected token.");
                        subtrees.Push(Parse(tokens, operators, new Queue<Operator>(waiting)));
                    }
                    string subtree = subtrees.Pop();
                    while (subtrees.Count > 0)
                    {
                        subtree = String.Format("({0}{2}{1})",
                            subtrees.Pop(),
                            subtree,
                            op.Symbol);
                    }
                    return subtree;
                }
            }
        }

        static void Main(string[] args)
        {
            List<Operator> operators = GetOperators();
            operators.Reverse();
            Queue<Token> tokens = new Queue<Token>(TokenizeInput(operators));
            string subtree = Parse(tokens, operators, new Queue<Operator>(operators));
            Console.WriteLine(subtree);
            Console.ReadKey();
        }
    }

    abstract class Token { }

    class BracketToken : Token
    {
        public enum BracketType
        {
            Left,
            Right
        }

        public BracketType Type;
    }

    class IntegerToken : Token
    {
        public int Value;
    }

    class OperatorToken : Token
    {
        public Operator Operator;
    }

    struct Operator
    {
        public string Symbol;
        public Associativity Associativity;

        public Operator(string symbol, Associativity precedence)
        {
            Symbol = symbol;
            Associativity = precedence;
        }

        public static Operator FromInput(string input)
        {
            string[] parts = input.Split(':');

            if (parts.Length != 2)
                throw new FormatException("Bad input: " + input);

            if (parts[0] == "(" || parts[0] == ")")
                throw new Exception("Cannot have bracket symbol for operator.");

            return new Operator(
                parts[0],
                (Associativity)Enum.Parse(typeof(Associativity), parts[1], true));
        }
    }

    enum Associativity
    {
        Left,
        Right
    }
}