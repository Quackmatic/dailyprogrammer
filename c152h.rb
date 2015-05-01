# reddit.com/r/DailyProgrammer
# Solution to Challenge #???: Minimum Spanning Tree

vertices = gets.chomp.to_i
adjacency = Array.new(vertices) { gets.chomp.split(',').map {|n| n.to_i } }.transpose # matrix input one liner

traversed_vertices = [0]
edges = []
alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

# using Prim's algorithm
while traversed_vertices.count < vertices do
  possible_verts = adjacency.map.with_index do |col, y|
    {column: col, index: y } # get indices of columns
  end.select do |col|
    traversed_vertices.include? col[:index] # exclude columns not traversed yet
  end.map do |col|
    col[:column].map.with_index do |edge_weight, x|
      {row: x, col: col[:index], weight: edge_weight} # collate edge data
    end.select do |vert|
      not traversed_vertices.include? vert[:row] # exclude rows already traversed
    end
  end.flatten
  possible_verts.select! {|vert| vert[:weight] >= 0} # get rid of -1s (ie. no edge)
  possible_verts.sort_by! {|vert| vert[:weight]} # sort
  best_match = possible_verts[0] # get shortest
  edges.push best_match
  traversed_vertices.push best_match[:row]
end

weight = edges.map {|edge| edge[:weight]}.inject {|wt, v| wt + v}
edges.map! {|edge| alphabet[edge[:col]] + alphabet[edge[:row]] }
puts weight
puts edges.join ','
