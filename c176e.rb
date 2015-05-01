def alpha_to_num(str, col=0)
  unless str.nil? || str.empty?
    return (alpha_to_num(str.slice(0, str.length - 1), col + 1)) * 26 +
      "abcdefghijklmnopqrstuvwxyz".index(str.downcase[str.length - 1]) + (col > 1 ? 1 : col)
  else
    0
  end
end

def cell_coords(str)
  return {x: alpha_to_num(str.slice /[A-Za-z]+/), y: str.slice(/[0-9]+/).to_i - 1}
end

def range(str)
  if str.include? ':'
    parts = str.split(':').map {|s| cell_coords s}
    rv = []
    (parts[0][:x]..parts[1][:x]).each do |x|
      (parts[0][:y]..parts[1][:y]).each do |y|
        rv << {x: x, y: y}
      end
    end
    return rv
  else
    return cell_coords(str)
  end
end

def specify(str)
  return str.split('&').map {|s| range(s)}.flatten
end

def select(str)
  sp = str.split '~'
  if sp.length == 1
    specify(str)
  elsif sp.length == 2
    dni = specify sp[1]
    return specify(sp[0]).reject {|c| dni.include? c}
  else
    raise 'Can\'t have more than one ~ in selector'
  end
end

selected = select(gets.chomp)
puts selected.length
selected.each do |cell|
  puts "#{cell[:x]}, #{cell[:y]}"
end