# reddit.com/r/DailyProgrammer
# Solution to Challenge #???: Intersecting Rectangles

class Rectangle
  attr_accessor :top, :left, :width, :height

  def initialize(p1, p2)
    x_coords = [p1[0], p2[0]].sort
    y_coords = [p1[1], p2[1]].sort
    @left = x_coords[0]; @width = x_coords[1] - @left
    @top = y_coords[0]; @height = y_coords[1] - @top
  end

  def vert_range
    return [@top, @height + @top]
  end

  def hoz_range
    return [@left, @width + @left]
  end

  def on_scanline(x)
    return x >= @left && x <= (@left + @width)
  end
end

class Array
  def get_pairs
    pairs = []

    for i in 0...(length - 1)
      pairs += [[self[i], self[i + 1]]]
    end

    return pairs
  end
end

def range_span(ranges)
  range_hist = ranges.map do |r|
    [[r[0], 1], [r[1], -1]]
  end.flatten(1).sort {|r, s| r[0] <=> s[0]}

  height = 0
  range_start = 0
  span = 0

  range_hist.each do |r|
    if r[1] == 1 && height == 0
      range_start = r[0]
    elsif r[1] == -1 && height == 1
      span += r[0] - range_start
    end
    height += r[1]
  end

  return span
end

rectangle_count = gets.chomp.to_i
input_rectangles = Array.new(rectangle_count) do
  input_data = gets.chomp.split(' ').map {|i| i.to_r}
  Rectangle.new([input_data[0], input_data[1]], [input_data[2], input_data[3]])
end
key_ranges = input_rectangles.map {|rect| rect.hoz_range}.flatten.uniq.sort.get_pairs

total_area = 0
key_ranges.each do |r|
  current_rectangles = input_rectangles.select {|rect| rect.on_scanline ((r[0] + r[1]) / 2.0)}
  inner_ranges = current_rectangles.map {|rect| rect.vert_range}
  span = range_span inner_ranges

  area = span * (r[1] - r[0])
  total_area += area
end

puts total_area.to_f
