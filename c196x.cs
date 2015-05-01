class Set<T> : IEquatable<Set<T>>, ICloneable
{
    private List<T> Members;
    private bool Not;

    private Set()
    {
        this.Members = new List<T>();
        this.Not = false;
    }

    public Set(params T[] members)
        : this()
    {
        foreach (T t in members)
        {
            if (!this.Members.Contains(t))
            {
                this.Members.Add(t);
            }
        }
    }

    public bool Contains(T item)
    {
        return this.Not ^ this.Members.Contains(item);
    }

    public static Set<T> Union(Set<T> a, Set<T> b)
    {
        if (!a.Not && !b.Not)
        {
            Set<T> result = new Set<T>();
            foreach (T t in a.Members)
            {
                result.Members.Add(t);
            }
            foreach (T t in b.Members)
            {
                if (!result.Members.Contains(t))
                {
                    result.Members.Add(t);
                }
            }
            return result;
        }
        else if (a.Not && !b.Not)
        {
            Set<T> result = new Set<T>();
            result.Not = true;
            foreach (T t in a.Members)
            {
                if (!b.Members.Contains(t))
                {
                    result.Members.Add(t);
                }
            }
            return result;
        }
        else if (!a.Not && b.Not)
        {
            Set<T> result = new Set<T>();
            result.Not = true;
            foreach (T t in b.Members)
            {
                if (!a.Members.Contains(t))
                {
                    result.Members.Add(t);
                }
            }
            return result;
        }
        else
        {
            Set<T> result = new Set<T>();
            result.Not = true;
            foreach (T t in a.Members)
            {
                if (!result.Members.Contains(t) && b.Members.Contains(t))
                {
                    result.Members.Add(t);
                }
            }
            foreach (T t in b.Members)
            {
                if (!result.Members.Contains(t) && a.Members.Contains(t))
                {
                    result.Members.Add(t);
                }
            }
            return result;
        }
    }

    public static Set<T> Intersection(Set<T> a, Set<T> b)
    {
        if (!a.Not && !b.Not)
        {
            Set<T> result = new Set<T>();
            foreach (T t in a.Members)
            {
                if (!result.Members.Contains(t) && b.Members.Contains(t))
                {
                    result.Members.Add(t);
                }
            }
            foreach (T t in b.Members)
            {
                if (!result.Members.Contains(t) && a.Members.Contains(t))
                {
                    result.Members.Add(t);
                }
            }
            return result;
        }
        else if (a.Not && !b.Not)
        {
            Set<T> result = new Set<T>();
            foreach (T t in b.Members)
            {
                if (!a.Members.Contains(t))
                {
                    result.Members.Add(t);
                }
            }
            return result;
        }
        else if (!a.Not && b.Not)
        {
            Set<T> result = new Set<T>();
            foreach (T t in a.Members)
            {
                if (!b.Members.Contains(t))
                {
                    result.Members.Add(t);
                }
            }
            return result;
        }
        else
        {
            Set<T> result = new Set<T>();
            result.Not = true;
            foreach (T t in a.Members)
            {
                if (!result.Members.Contains(t))
                {
                    result.Members.Add(t);
                }
            }
            foreach (T t in b.Members)
            {
                if (!result.Members.Contains(t))
                {
                    result.Members.Add(t);
                }
            }
            return result;
        }
    }

    public static Set<T> Complement(Set<T> a)
    {
        Set<T> result = (Set<T>)a.Clone();
        result.Not = !a.Not;
        return result;
    }

    public static Set<T> operator +(Set<T> a, Set<T> b)
    {
        return Set<T>.Union(a, b);
    }

    public static Set<T> operator *(Set<T> a, Set<T> b)
    {
        return Set<T>.Intersection(a, b);
    }

    public static Set<T> operator !(Set<T> a)
    {
        return Set<T>.Complement(a);
    }

    public bool Equals(Set<T> other)
    {
        if ((object)other == null) return false;
        if (other.Not != this.Not) return false;

        foreach (T t in this.Members)
        {
            if (!(other.Members.Contains(t)))
            {
                return false;
            }
        }

        return true;
    }

    public override bool Equals(object obj)
    {
        if (obj is Set<T>)
        {
            return Equals(obj as Set<T>);
        }
        else
        {
            return false;
        }
    }

    public static bool operator ==(Set<T> a, Set<T> b)
    {
        return a.Equals(b);
    }

    public static bool operator !=(Set<T> a, Set<T> b)
    {
        return !a.Equals(b);
    }

    public object Clone()
    {
        return new Set<T>(this.Members.ToArray());
    }

    public override string ToString()
    {
        return String.Format("{{{0}}}{1}", String.Join(", ", Members.OrderBy(i => i).ToArray()), Not ? "'" : "");
    }
}