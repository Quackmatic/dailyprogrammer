# center a string, padded by spaces
def tcenter(n, str)
  side = (n - str.length).to_f / 2.0
  return (' ' * side.ceil) + str + (' ' * side.floor)
end

# factorise a factor tree further
# end points (primes) are stored as :type => :atom
# branch points are stored as :type => :branch, with branches :a and :b
# numbers are factorised top-down
# width and height of current branch are kept updated and calculated bottom-up
def fact(n)
  range = (2..(Math.sqrt(n).ceil))
  range.to_a.reverse.each do |i|
    if (n % i == 0 && n != i)
      hash = rand(2) == 0 ? {:a => fact(i), :b => fact(n / i)} : {:a => fact(n / i), :b => fact(i)}
      hash[:value] = n
      hash[:type] = :branch
      hash[:width] = hash[:a][:width] + hash[:b][:width] + 1
      hash[:height] = [hash[:a][:height], hash[:b][:height]].max + 2
      return hash
    end
  end
  return {:value => n, :type => :atom, :width => n.to_s.length + 1, :height => 1}
end

# prints a string to an array
def sprint(x, y, a, s, w)
  t = tcenter(w, s)
  (0..(t.length - 1)).each do |i|
    a[x + i][y] = t[i] if t[i] != ' '
  end
end

# prints a tree
def tprint(a, tree, x = 0, y = 0)
  if tree[:type] == :atom
    sprint(x, y, a, tree[:value].to_s, tree[:width])
  else
    center_point = (x + ((tree[:a][:width] / 2) + (tree[:a][:width] + 1 + (tree[:b][:width] / 2))) / 2.0).floor
    ((tree[:a][:width] / 2)..(tree[:a][:width] + 1 + (tree[:b][:width] / 2))).each do |i|
      a[x + i][y + 2] = '-'
    end
    a[center_point][y + 1], a[center_point][y + 2] = '|', '+'
    sprint(x, y, a, tree[:value].to_s, tree[:width])
    tprint(a, tree[:a], x, y + 2)
    tprint(a, tree[:b], x + 1 + tree[:a][:width], y + 2)
  end
end

# logic
factors = fact(gets.chomp.to_i)
tspace = Array.new(factors[:width]) { Array.new(factors[:height], ' ') }
tprint(tspace, factors)
(tspace.transpose.map{|a| a.join ''}).each do |s|
  puts s
end