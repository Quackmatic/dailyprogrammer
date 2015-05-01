class Program
{
    static void Main(string[] args)
    {
        Console.Title = "c188h";
        new Program().Run();
    }

    char[,] GetGrid(out int width, out int height)
    {
        int[] size = Console
            .ReadLine()
            .Split(' ')
            .Select(s => Convert.ToInt32(s))
            .ToArray();
        if (size.Length != 2) throw new FormatException();

        char[,] grid = new char[size[0], size[1]];

        for (int j = 0; j < size[1]; j++)
        {
            string data = Console.ReadLine();
            if(data.Length != size[0]) throw new FormatException();

            for (int i = 0; i < data.Length; i++)
            {
                grid[i, j] = data[i];
            }
        }

        width = size[0];
        height = size[1];
        return grid;
    }

    Path GetLongestPath(char[,] grid, int width, int height)
    {
        List<Point> nonTraversedPoints = new List<Point>();
        for (int i = 0; i < width; i++)
            for (int j = 0; j < height; j++)
                nonTraversedPoints.Add(new Point(i, j));

        Path longestPath = new Path();

        while (nonTraversedPoints.Count > 0)
        {
            Point current = nonTraversedPoints[0];

            List<Point> path = new List<Point>();
            while (true)
            {
                int repeatIndex = path.FindIndex(p => current == p);
                if (repeatIndex != -1) // found a cycle
                {
                    int cycleLength = path.Count - repeatIndex;
                    if (cycleLength > longestPath.Length)
                    {
                        Point[] cyclePoints = new Point[cycleLength];
                        path.CopyTo(repeatIndex, cyclePoints, 0, cycleLength);
                        longestPath = new Path()
                        {
                            Length = cycleLength,
                            Points = cyclePoints
                        };
                    }
                    break;
                }
                else
                {
                    Point next = current;
                    switch (grid[current.X, current.Y])
                    {
                        case '^': next.Y--; break;
                        case 'v': next.Y++; break;
                        case '<': next.X--; break;
                        case '>': next.X++; break;
                    }
                    next.X = (next.X + width) % width;
                    next.Y = (next.Y + height) % height;
                    path.Add(current);
                    current = next;

                    if (!nonTraversedPoints.Any(q => current == q))
                        break;
                }
            }

            path.ForEach(pathPoint => nonTraversedPoints.Remove(pathPoint));
        }
        return longestPath;
    }

    void Run()
    {
        int width, height;
        var grid = GetGrid(out width, out height);

        Path longest = GetLongestPath(grid, width, height);
        Console.WriteLine();
        Console.WriteLine("Longest path length: {0}", longest.Length);

        for (int j = 0; j < height; j++)
        {
            Console.WriteLine();
            for (int i = 0; i < width; i++)
            {
                bool inPath = longest.InPath(i, j);
                Console.ForegroundColor = inPath ? ConsoleColor.Red : ConsoleColor.White;
                Console.Write(grid[i, j]);
            }
        }
        Console.ResetColor();
        Console.ReadKey();
    }

    struct Point
    {
        public int X, Y;

        public Point(int x, int y)
        {
            X = x;
            Y = y;
        }

        public override bool Equals(object obj)
        {
            if (obj is Point)
            {
                Point p = (Point)obj;
                return X == p.X && Y == p.Y;
            }
            else
            {
                return false;
            }
        }

        public override int GetHashCode()
        {
            return Y ^ (X >> 16) ^ (X << 16);
        }

        public override string ToString()
        {
            return String.Format("({0}, {1})", X, Y);
        }

        public static bool operator ==(Point p1, Point p2)
        {
            return p1.X == p2.X && p1.Y == p2.Y;
        }

        public static bool operator !=(Point p1, Point p2)
        {
            return p1.X != p2.X || p1.Y != p2.Y;
        }
    }

    class Path
    {
        public Point[] Points;
        public int Length;

        public Path()
        {
            Points = new Point[0];
            Length = 0;
        }

        public bool InPath(int x, int y)
        {
            return Points.Any(p => p.X == x && p.Y == y);
        }

        public bool InPath(Point p)
        {
            return Points.Any(q => p == q);
        }
    }
}