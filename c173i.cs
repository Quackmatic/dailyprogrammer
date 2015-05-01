using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;

namespace AdvancedAnt
{
    class Program
    {
        static void Main(string[] args)
        {
            Color[] colors = new Color[] {
                Color.White,
                Color.Black,
                Color.Red,
                Color.Lime,
                Color.Blue,
                Color.Yellow,
                Color.Cyan,
                Color.Magenta,
                Color.Gray,
                Color.Green
            };
            char[] states = Console.ReadLine().ToUpper().ToCharArray();
            int steps = Convert.ToInt32(Console.ReadLine());
            Ant ant = new Ant()
            {
                Direction = Direction.Up,
                Grid = new ExtendableGrid<int>(1, 1, () => 0)
            };
            for (int i = 0; i < steps; i++)
            {
                ant.Step(states);
            }
            Bitmap saveBitmap = new Bitmap(ant.Grid.Width, ant.Grid.Height);
            for (int i = 0; i < ant.Grid.Height; i++)
            {
                for (int j = 0; j < ant.Grid.Width; j++)
                {
                    saveBitmap.SetPixel(j, i, colors[ant.Grid[j, i]]);
                }
            }
            saveBitmap.Save("langton.png");
            Process.Start("langton.png");
        }
    }

    struct Ant
    {
        public int X;
        public int Y;
        public Direction Direction;
        public ExtendableGrid<int> Grid;

        public void Move()
        {
            switch (Direction)
            {
                case AdvancedAnt.Direction.Up:
                    MoveUp(); break;
                case AdvancedAnt.Direction.Down:
                    MoveDown(); break;
                case AdvancedAnt.Direction.Left:
                    MoveLeft(); break;
                case AdvancedAnt.Direction.Right:
                    MoveRight(); break;
            }
        }

        public void StateChange(int states)
        {
            int state = Grid[X, Y];
            state = (state + 1) % states;
            Grid[X, Y] = state;
        }

        public void TurnAnticlockwise()
        {
            Direction = (Direction)(((int)Direction + 3) % 4);
        }

        public void TurnClockwise()
        {
            Direction = (Direction)(((int)Direction + 1) % 4);
        }

        public void Turn(char direction)
        {
            if (direction == 'L') TurnAnticlockwise();
            if (direction == 'R') TurnClockwise();
        }

        public void Step(char[] states)
        {
            int current = Grid[X, Y];
            Turn(states[current]);
            StateChange(states.Length);
            Move();
        }

        public void MoveLeft()
        {
            if (X == 0)
            {
                Grid.ExtendLeft(1, () => 0);
            }
            else
            {
                X--;
            }
        }

        public void MoveRight()
        {
            if (X == Grid.Width - 1)
            {
                Grid.ExtendRight(1, () => 0);
            }
            X++;
        }

        public void MoveUp()
        {
            if (Y == 0)
            {
                Grid.ExtendTop(1, () => 0);
            }
            else
            {
                Y--;
            }
        }

        public void MoveDown()
        {
            if (Y == Grid.Height - 1)
            {
                Grid.ExtendBottom(1, () => 0);
            }
            Y++;
        }
    }

    class ExtendableGrid<T>
    {
        private List<List<T>> Grid;

        public int Width
        {
            get;
            private set;
        }

        public int Height
        {
            get;
            private set;
        }

        public T this[int x, int y]
        {
            get
            {
                if (x < 0 || x >= Width) throw new IndexOutOfRangeException("x");
                if (y < 0 || y >= Height) throw new IndexOutOfRangeException("y");
                return Grid[x][y];
            }
            set
            {
                if (x < 0 || x >= Width) throw new IndexOutOfRangeException("x");
                if (y < 0 || y >= Height) throw new IndexOutOfRangeException("y");
                Grid[x][y] = value;
            }
        }

        public ExtendableGrid(int width, int height, Func<T> initialValue)
        {
            Width = width;
            Height = height;
            Grid = new List<List<T>>(Width);
            for (int i = 0; i < Width; i++)
            {
                var gridColumn = new List<T>(Height);
                for (int j = 0; j < Height; j++)
                {
                    gridColumn.Add(initialValue());
                }
                Grid.Add(gridColumn);
            }
        }

        public void ExtendLeft(int count, Func<T> initialValue)
        {
            for (int i = 0; i < count; i++)
            {
                var newGridColumn = new List<T>(Height);
                for (int j = 0; j < Height; j++)
                {
                    newGridColumn.Add(initialValue());
                }
                Grid.Insert(0, newGridColumn);
            }
            Width += count;
        }

        public void ExtendRight(int count, Func<T> initialValue)
        {
            for (int i = 0; i < count; i++)
            {
                var newGridColumn = new List<T>(Height);
                for (int j = 0; j < Height; j++)
                {
                    newGridColumn.Add(initialValue());
                }
                Grid.Add(newGridColumn);
            }
            Width += count;
        }

        public void ExtendTop(int count, Func<T> initialValue)
        {
            for (int i = 0; i < Width; i++)
            {
                for (int j = 0; j < count; j++)
                {
                    Grid[i].Insert(0, initialValue());
                }
            }
            Height += count;
        }

        public void ExtendBottom(int count, Func<T> initialValue)
        {
            for (int i = 0; i < Width; i++)
            {
                for (int j = 0; j < count; j++)
                {
                    Grid[i].Add(initialValue());
                }
            }
            Height += count;
        }
    }

    enum Direction
    {
        Up = 0,
        Right = 1,
        Down = 2,
        Left = 3
    }
}