# reddit.com/r/DailyProgrammer
# Solution to Challenge #140: Adjacency Matrix

nodes, lines = gets.chomp.split(' ').map {|s| s.to_i}
mat = Array.new(nodes) {Array.new(nodes) {0}}

(1..lines).step 1 do |x|
  line = gets.chomp.split('->').map {|s| s.split(' ').map {|t| t.to_i}.compact}

  combos = line.first.product line.last
  combos.each do |b|
    mat[b[0]][b[1]] = 1
  end
end

mat.each do |x|
  puts x.join
end