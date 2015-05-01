
static class Program
{
    static char[,] GetBoard(Vector boardSize)
    {
        char[,] board = new char[boardSize.X, boardSize.Y];

        for (int j = 0; j < boardSize.Y; j++)
        {
            string line = Console.ReadLine();

            if (line.Length != boardSize.X)
                throw new Exception("Bad line length on line " + (j + 1).ToString());

            for (int i = 0; i < boardSize.X; i++)
            {
                board[i, j] = line[i];
            }
        }

        return board;
    }

    static void PrintBoard(this char[,] board)
    {
        int width = board.GetLength(0), height = board.GetLength(1);

        for (int j = 0; j < height; j++)
        {
            char[] line = new char[width];
            for (int i = 0; i < width; i++)
            {
                line[i] = board[i, j];
            }
            Console.WriteLine(new string(line));
        }
    }

    static void FloodFill(char[,] board, FillTarget target)
    {
        int width = board.GetLength(0), height = board.GetLength(1);
        List<Vector> visited = new List<Vector>();
        char startingSource = board[target.Location.X, target.Location.Y];

        Action<Vector> fillRecursive = null;
        fillRecursive = delegate(Vector v)
         {
             if (board[v.X, v.Y] != startingSource)
                 return; // source character check
             if (visited.Contains(v))
                 return; // visited check

             board[v.X, v.Y] = target.Character;
             visited.Add(v);
             fillRecursive(new Vector((width + v.X - 1) % width, (height + v.Y) % height));
             fillRecursive(new Vector((width + v.X + 1) % width, (height + v.Y) % height));
             fillRecursive(new Vector((width + v.X) % width, (height + v.Y - 1) % height));
             fillRecursive(new Vector((width + v.X) % width, (height + v.Y + 1) % height));
         };
        fillRecursive(target.Location);
    }

    static void Main(string[] args)
    {
        var board = GetBoard(Vector.FromString(Console.ReadLine()));
        FloodFill(board, FillTarget.FromString(Console.ReadLine()));
        board.PrintBoard();
        Console.ReadKey();
    }
}

struct Vector
{
    public int X, Y;

    public Vector(int x, int y)
    {
        X = x;
        Y = y;
    }

    public static Vector FromString(string s)
    {
        int[] input = s
            .Split(' ')
            .Select(Int32.Parse)
            .ToArray();
        return new Vector(input[0], input[1]);
    }

    public override bool Equals(object obj)
    {
        if (obj == null) return false;
        if (obj is Vector)
        {
            Vector v = (Vector)obj;
            return v.X == this.X &&
                   v.Y == this.Y;
        }
        return false;
    }
}

struct FillTarget
{
    public Vector Location;
    public char Character;

    public FillTarget(Vector location, char character)
    {
        Location = location;
        Character = character;
    }

    public static FillTarget FromString(string s)
    {
        string[] input = s
            .Split(' ');
        return new FillTarget(
            new Vector(
                Int32.Parse(input[0]),
                Int32.Parse(input[1])),
            Char.Parse(input[2]));
    }
}