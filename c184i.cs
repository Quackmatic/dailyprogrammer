class Program
{
    static Random random = new Random();

    static void Main(string[] args)
    {
        InputData data = GetInput();

        int sampleSize = 1024;
        Bitmap chart = new Bitmap(data.SimulationTime, sampleSize);
        var colors = CreateColors(data);

        string[] sample = new string[sampleSize];
        for (int i = 0; i < sample.Length; i++) sample[i] = data.Chain.Keys.First();

        for (int t = 0; t < data.SimulationTime; t++)
        {
            Plot(chart, t, sample, colors);
            Decay(sample, data);
            Sort(sample, data);
            Console.Title = "T: " + t.ToString();
        }

        var results = CountUp(sample);
        foreach (var result in results)
        {
            Console.WriteLine("{0}: {1:0.00}%", result.Key, 100.0 * result.Value / sample.Length);
        }
        Console.ReadKey();

        chart.Save("Data.png");
        Process.Start("Data.png");
    }

    static Dictionary<string, double> CountUp(string[] sample)
    {
        Dictionary<string, double> results = new Dictionary<string, double>(sample.Length);
        foreach(string nucleus in sample){
            if(results.ContainsKey(nucleus)) results[nucleus]++;
            else results.Add(nucleus, 1);
        };
        return results;
    }

    static Dictionary<string, Color> CreateColors(InputData data)
    {
        Dictionary<string, Color> colors = new Dictionary<string, Color>(data.Chain.Count);
        Color[] fixedColors = new Color[]
        {
            Color.Red,
            Color.Orange,
            Color.Yellow,
            Color.LimeGreen,
            Color.Lime,
            Color.Cyan,
            Color.Teal,
            Color.Blue,
            Color.DarkBlue,
            Color.Purple,
            Color.Fuchsia
        };

        int index = 0;
        foreach (string isotope in data.Chain.Keys)
        {
            colors.Add(isotope,
                isotope == data.Chain.Keys.Last() ?
                Color.Black :
                fixedColors[index++]
                );
        }

        return colors;
    }

    static void Sort(string[] sample, InputData data)
    {
        var isotopes = data.Chain.Keys.ToArray();
        List<int> sampleList = new List<int>(sample.Length);
        for (int i = 0; i < sample.Length; i++)
            sampleList.Add(Array.IndexOf(isotopes, sample[i]));
        sampleList.Sort();
        for (int i = 0; i < sample.Length; i++)
            sample[i] = isotopes[sampleList[i]];
    }

    static void Decay(string[] sample, InputData data)
    {
        var isotopes = data.Chain.Keys.ToArray();

        for (int i = 0; i < sample.Length; i++)
        {
            string isotope = sample[i];
            double lambda = data.Chain[isotope];
            if (lambda > 0 && random.NextDouble() < lambda)
            {
                int nextIsotopeIndex = Array.IndexOf(isotopes, isotope) + 1;
                if (nextIsotopeIndex == isotopes.Length)
                {
                    throw new Exception("Never-ending decay chain!");
                }
                else
                {
                    sample[i] = isotopes[nextIsotopeIndex];
                }
            }
        }
    }

    static void Plot(Bitmap plot, int t, string[] sample, Dictionary<string, Color> nucleusColors)
    {
        for (int i = 0; i < sample.Length; i++)
        {
            plot.SetPixel(t, i, nucleusColors[sample[i]]);
        }
    }

    static InputData GetInput()
    {
        Console.Write("Simulation time (s): ");
        InputData data = new InputData(Int32.Parse(Console.ReadLine()));

        Console.Write("Decay chain: ");
        var nucleiInChain = Console.ReadLine().Split(new string[] { "->" }, StringSplitOptions.None);

        foreach (var nucleus in nucleiInChain)
        {
            Console.Write("{0}: ", nucleus);
            data.Chain.Add(nucleus, Double.Parse(Console.ReadLine()));
        }

        return data;
    }
}

class InputData
{
    public int SimulationTime;
    public Dictionary<string, double> Chain = new Dictionary<string,double>();

    public InputData(int simulationTime)
    {
        SimulationTime = simulationTime;
    }
}