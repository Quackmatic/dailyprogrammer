o_swamp = Array.new(10) { gets.strip.chars }
swamp = o_swamp.map {|r| r.clone}
start=(0..9).map {|y| (0..9).map {|x| [x, y]}}.flatten(1).select{|(x, y)| swamp[y][x]=='@'}.first
(puts "No starting location."; exit) if start == nil
(0..9).map {|y| (0..9).map {|x|
  swamp[y][x] = 'N' if (x >= 9 || y >= 9 || [0, 1].product([0, 1]).any? {|(i, j)|
    swamp[y + j][x + i] == 'O' })}}
queue = {start => []}
visited = [start]
until queue.empty?
  x, y, *path = queue.shift.flatten
  if [0, 1].product([0, 1]).any?{|(i, j)| o_swamp[y+j][x+i] == '$'}
    path_coords = (path << x << y).each_slice(2)
    o_swamp.each.with_index {|l, y| puts l.map.with_index {|c, x|
      [0, -1].product([0, -1]).map {|(i, j)| [x + i, y + j]}
      .any? {|c| path_coords.include?(c)} ? '&' : c }.join ''}
    exit
  end
  [[0, 1], [0, -1], [1, 0], [-1, 0]]
    .reject {|(i, j)| x+i < 0 || x+i > 9 || y+j < 0 || y+j > 9 ||
                      swamp[y + j][x + i] == 'N' ||
                      visited.include?([x + i, y + j])}
    .each {|(i, j)| visited << [x+i, y+j]; queue[[x+i, y+j]] = path + [x, y]}
end
puts "No path to gold"
