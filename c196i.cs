static class Program
{
    static string Encrypt(string plain, int railCount)
    {
        string[] rails = new string[railCount];
        int i;
        for (i = 0; i < railCount; i++)
        {
            rails[i] = "";
        }
        for (i = 0; i < plain.Length; i++)
        {
            rails[(railCount - 1) - Math.Abs((railCount - 1) - i % (railCount * 2 - 2))] += plain[i];
        }
        return String.Join("", rails);
    }

    static string Decrypt(string cipher, int railCount)
    {
        char[] str = new char[cipher.Length];
        int k = 0, b = railCount * 2 - 2;
        for (int i = 0; i < cipher.Length; i += b)
        {
            str[i] = cipher[k++];
        }
        for (int i = railCount - 2; i >= 1; i--)
        {
            int l = (cipher.Length + b - 1) / b;
            for (int j = 0; j < l; j++)
            {
                int a = j * b + railCount - 1 - i;
                if (a >= cipher.Length) break;
                str[a] = cipher[k++];

                a = j * b + railCount - 1 + i;
                if (a >= cipher.Length) break;
                str[a] = cipher[k++];
            }
        }
        for (int i = railCount - 1; i < cipher.Length; i += b)
        {
            str[i] = cipher[k++];
        }
        return new string(str);
    }

    static void Main(string[] args)
    {
        string input;
        Console.WriteLine("Empty string to exit.");
        while ((input = Console.ReadLine()).Length > 0)
        {
            string[] parts = input.Split(new[] { " " }, 3, StringSplitOptions.None);
            int rails = Int32.Parse(parts[1]);
            if (parts[0].ToLower() == "dec")
                Console.WriteLine(Decrypt(parts[2], rails));
            else if (parts[0].ToLower() == "enc")
                Console.WriteLine(Encrypt(parts[2], rails));
            else
                Console.WriteLine("Unknown command: {0}", parts[0]);
        }
    }
}