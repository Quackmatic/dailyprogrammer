alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
vertices = gets.chomp.to_i
adjacency = Array.new(vertices) { gets.chomp.split(',').map {|n| n.to_i } }.transpose
source, sink = *(gets.chomp.split(' ').map {|c| alphabet.index c})
dist = Array.new(vertices, -1)
dist[source] = 0
traversed = []
until traversed.length == vertices
  active_vertex = (0...vertices)
    .reject {|v| dist[v] == -1}
    .reject {|v| traversed.include? v}
    .sort {|v, w| dist[v] <=> dist[w]}
    .first
  (0...vertices).each do |v|
    weight = adjacency[active_vertex][v]
    dist[v] = [dist[v], weight + dist[active_vertex]]
      .reject {|d| d < 0}
      .min if weight >= 0
  end
  traversed.push active_vertex
end
puts dist[sink]
path = [sink]
until path.last == source
  path.push (0...vertices)
    .select {|v| dist[path.last] - adjacency[path.last][v] == dist[v]}
    .first
end
path = path.reverse.map {|v| alphabet[v]}.join ''
puts path