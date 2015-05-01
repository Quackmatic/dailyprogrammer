module C208i
  class Gradient
    def initialize(gradient)
      if gradient.length > 0
        @chars = gradient.chars
      else
        raise Exception.new("Gradient string must not be empty.")
      end
    end

    def interpolate(x)
      if x <= 0.0
        @chars.first
      elsif x >= 1.0
        @chars.last
      else
        @chars[(x * @chars.length).to_i]
      end
    end

    def lookup(c1)
      if c1.length == 1
        @chars.each.with_index do |c2, i|
          return i.to_f / (@chars.length - 1).to_f if c1 == c2
        end
        raise Exception.new("Character #{c1} is not in this gradient.")
      else
        raise Exception.new("Lookup character must be only 1 character long. " +
                            "(#{c1.length} given)")
      end
    end
  end

  class LinearGradient < Gradient
    def initialize(gradient, x1, y1, x2, y2)
      super(gradient)
      @u, @v = x2 - x1, y2 - y1
      @start = along(x1, y1)
    end

    def [](x, y, e=0.0)
      e + along(x, y) - @start
    end

  private
    def along(x, y)
      (x.to_f * @u + y.to_f * @v) / (@u * @u + @v * @v)
    end
  end

  class RadialGradient < Gradient
    def initialize(gradient, x, y, r)
      super(gradient)
      @x, @y, @r = x, y, r
    end

    def [](x, y, e=0.0)
      e + Math.sqrt((x - @x) ** 2 + (y - @y) ** 2) / @r
    end
  end

  class Board
    attr_reader :width, :height

    def initialize(width, height)
      if width > 0 && height > 0
        if block_given?
          @width, @height = width, height
          @default = yield
          @board = Array.new(height) { Array.new(width) { yield } }
        else
          raise Exception.new("No block given.")
        end
      else
        raise Exception.new("Invalid board size: width #{width}, height #{height}")
      end
    end

    def in_bounds?(x, y)
      x >= 0 && y >= 0 &&
        x < self.width && y < self.height
    end

    def [](x, y)
      if in_bounds?(x, y)
        @board[y][x]
      else
        @default
      end
    end

    def []=(x, y, char)
      if in_bounds?(x, y)
        @board[y][x] = char
      else
        @default
      end
    end
    
    def print
      @board.each {|row| puts row.join('') }
    end
  end

  class Printer
    def initialize(width, height)
      if width > 0 && height > 0
        @width, @height = width, height
      else
        raise Exception.new("Invalid size: width #{width}, height #{height}.")
      end
    end

    def print(gradient)
      board = Board.new(@width, @height) { ' ' }
      (0...@height).each do |y|
        (0...@width).each do |x|
          board[x, y] = gradient.interpolate gradient[x, y]
        end
      end
      board.print
    end
  end
end

p = C208i::Printer.new(*gets.chomp.split(' ').map{|s| s.to_i})
characters = gets.chomp
gradient_input = gets.chomp.split(' ')
gradient_type, gradient_args = gradient_input.first, gradient_input.drop(1).map{|s| s.to_i}
g = { 'linear' => C208i::LinearGradient, 'radial' => C208i::RadialGradient }[gradient_type].new(characters, *gradient_args)
p.print g
