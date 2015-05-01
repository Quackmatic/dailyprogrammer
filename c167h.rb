# Vertex order
def ord(adj, n)
  return adj[n].select {|m| m != -1}.length
end

# Get shortest path length
def dijkstra(adj, source, sink)
  vertices = adj.length
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
      weight = adj[active_vertex][v]
      dist[v] = [dist[v], weight + dist[active_vertex]]
        .reject {|d| d < 0}
        .min if weight >= 0
    end
    traversed.push active_vertex
  end
  dist[sink]
end

alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
vertices = gets.chomp.to_i
adjacency = Array.new(vertices) { gets.chomp.split(',').map {|n| n.to_i } }.transpose

odd = (0...vertices).to_a.select {|n| ord(adjacency, n).odd?}

puts "(info) Odd(#{odd.length}): #{odd.map {|v| alphabet[v]}.join ' '}"

if odd.length == 0
  puts "Any"
elsif odd.length == 2
  puts odd.map {|v| alphabet[v]}.join ' '
else
  until odd.length == 2
    combo = odd.combination(2)
      .map    {|c| { :comb => c, :dist => dijkstra(adjacency, c.first, c.last)}}
      .sort   {|c, d| c[:dist] <=> d[:dist]}
      .first[:comb]
      .each   {|v| odd.delete v}
    puts "(info) Keeping vertex #{combo.map {|v| alphabet[v]}.join ''}"
  end
  puts odd.map {|v| alphabet[v]}.join ' '
end