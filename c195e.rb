def dir(s)
  s
    .split('/')
    .select {|t| !t.empty? }
end

def resolve(p, l)
  resolved = []
  p.each do |d|
    resolved.push d
    unresolved = true
    while unresolved
      unresolved = false
      l.each do |k, v|
        resolved, unresolved = v.clone, true if resolved == k
      end
    end
  end
  resolved
end

swaps = {}
gets.chomp.to_i.times do
  swaps.store(*gets.chomp.split(':', 2).map {|s| resolve(dir(s), swaps)})
end

puts "/#{resolve(dir(gets.chomp), swaps).join '/'}"
