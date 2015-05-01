# reddit.com/r/DailyProgrammer
# Solution to Challenge #145: Tree Generation

def print_tree(n, trunk, leaves)
  (1..n).step(2) do |a|
    side_spaces = " " * ((n - a) / 2)
    puts side_spaces + leaves * a
  end
  puts " " * ((n - 3) / 2) + trunk * 3
end

print_tree(7, "#", "|") # Example Usage