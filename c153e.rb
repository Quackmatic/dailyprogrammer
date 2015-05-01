# reddit.com/r/DailyProgrammer
# Solution to Challenge #???: Pascal's Pyramid
 
def fac(n)
  n < 2 ? 1 : n * fac(n - 1)
end

def tri(n)
  (0..n).to_a
    .map {|x| fac(n) / (fac(x) * fac(n - x))}
end

def pym(n)
  tri(n).to_a
    .map.with_index {|x, i| tri(i).map {|y| y * x}}
end

# most code after this is to make it look pretty

size = gets.chomp.to_i
layer = pym(size - 1)
largest = layer.flatten.reduce {|x, y| x > y ? x : y }.to_s.length

puts layer
  .map {|a| a.map {|n| n.to_s.center(largest, ' ')}.join(' ').center(size * largest + size - 1, ' ') }
  .join "\n"
