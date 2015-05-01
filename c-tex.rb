module Equations
  class Container
    def initialize(things)
      @things = things
    end

    def width
      [1, @things.reduce(0) { |s, t| s + t.width }].max
    end

    def desc_height
      @things.map { |t| t.desc_height }.max
    end

    def asc_height
      @things.map { |t| t.asc_height }.max
    end

    def height
      self.desc_height + self.asc_height + 1
    end

    def draw_to(board, x_start, y)
      x = x_start
      @things.each do |thing|
        thing.draw_to(board, x, y)
        x += thing.width
      end
    end

    def to_lines
      board = Array.new(self.height) { Array.new(self.width) { ' ' } }
      self.draw_to(board, 0, self.asc_height)
      board.map {|row| row.join }
    end
  end

  class Box
    attr_reader :width, :desc_height, :asc_height

    def initialize(width, desc_height, asc_height, fill)
      @width, @desc_height, @asc_height, @fill = width, desc_height, asc_height, fill
    end

    def height
      self.desc_height + self.asc_height + 1
    end

    def draw_to(board, x, y)
      (x...x + self.width).each do |i|
        (y - self.asc_height..y + self.desc_height).each do |j|
          board[j][i] = @fill
        end
      end
    end
  end

  class Text
    def initialize(text)
      @text = text
    end

    def width
      @text.length
    end

    def desc_height
      0
    end

    def asc_height
      0
    end

    def height
      1
    end

    def draw_to(board, x_start, y)
      x = x_start
      @text.each_char do |c|
        board[y][x] = c
        x += 1
      end
    end
  end

  class Fraction
    def initialize(top, bottom)
      @top, @bottom = top, bottom
    end

    def width
      [@top.width, @bottom.width].max
    end

    def desc_height
      @bottom.height
    end

    def asc_height
      @top.height
    end

    def height
      self.desc_height + self.asc_height + 1
    end

    def draw_to(board, x, y)
      (x...x + width).each {|x0| board[y][x0] = '-' }
      @top.draw_to(board, x + (self.width - @top.width) / 2, y - @top.desc_height - 1)
      @bottom.draw_to(board, x + (self.width - @bottom.width) / 2, y + @bottom.asc_height + 1)
    end
  end

  class Integral
    def initialize(content, low, high)
      @content, @low, @high = content, low, high
    end

    def limit_width
      ws = [0]
      ws << @low.width - 1 if @low
      ws << @high.width if @high
      ws.max
    end

    def content_outset
      @content.height > 1 ? self.limit_width + 1 : 0
    end

    def width
      self.limit_width + 3 + [1, @content.width + self.content_outset - 1].max
    end

    def desc_height
      @content.desc_height + (@low ? @low.height : 1)
    end

    def asc_height
      @content.asc_height + (@high ? @high.height : 1)
    end

    def height
      self.desc_height + self.asc_height + 1
    end

    def draw_to(board, x, y)
      (y - @content.asc_height..y + @content.desc_height).each {|j| board[j][x + 1] = '|' }
      board[y - @content.asc_height - 1][x + 1] = board[y + @content.desc_height + 1][x + 1] = '/'
      board[y - @content.asc_height - 1][x + 2] = board[y + @content.desc_height + 1][x] = '\\'
      @low.draw_to(board, x + 2, y + @content.desc_height + 1) if @low
      @high.draw_to(board, x + 3, y - @content.asc_height - 1) if @high
      @content.draw_to(board, x + 2 + self.content_outset, y)
    end
  end

  class Brackets
    def initialize(content)
      @content = content
    end

    def width
      @content.width + 2
    end

    def desc_height
      @content.desc_height
    end

    def asc_height
      @content.asc_height
    end

    def height
      self.desc_height + self.asc_height + 1
    end

    def draw_to(board, x, y)
      @content.draw_to(board, x + 1, y)
      if @content.height > 1
        board[y - self.asc_height][x] = board[y + self.desc_height][x + @content.width + 1] = '/'
        board[y + self.desc_height][x] = board[y - self.asc_height][x + @content.width + 1] = '\\'
        (y - self.asc_height + 1..y + self.desc_height - 1).each {|y| board[y][x] = board[y][x + @content.width + 1] = '|' }
      else
        board[y][x], board[y][x + @content.width + 1] = '(', ')'
      end
    end
  end

  class Script
    def initialize(base, sub=nil, sup=nil, reversed=false)
      raise "Script must have a sub or super block." unless sup || sub
      @base, @sub, @sup = base, sub, sup
      @reversed = reversed
    end

    def script_width
      [@sub, @sup].compact.map {|thing| thing.width}.max
    end

    def width
      @base.width + self.script_width
    end

    def desc_height
      @base.desc_height + (@sub ? @sub.height : 0)
    end

    def asc_height
      @base.asc_height + (@sup ? @sup.height : 0)
    end

    def height
      self.desc_height + self.asc_height + 1
    end

    def draw_to(board, x, y)
      unless @reversed
        base_x, script_x = x, x + @base.width
      else
        base_x, script_x = x + self.script_width, x
      end
      @base.draw_to(board, base_x, y)
      @sub.draw_to(board, script_x, y + @base.desc_height + @sub.asc_height + 1) if @sub
      @sup.draw_to(board, script_x, y - @base.asc_height - @sup.desc_height - 1) if @sup
    end
  end

  class Radical
    def initialize(base, power=nil)
      @base, @power = base, power
    end

    def width
      @base.width + [@base.height, @power ? @power.width : 1].max
    end

    def desc_height
      @base.desc_height
    end

    def asc_height
      @base.asc_height + (@power ? @power.height : 1)
    end

    def height
      self.desc_height + self.asc_height + 1
    end

    def draw_to(board, x, y)
      power_width = @power ? [0, @power.width - @base.height].max : 0
      @power.draw_to(board, x + power_width + @base.height - @power.width, y - @base.asc_height - 1 - @power.desc_height) if @power
      (0...@base.height).each do |i|
        board[y + self.desc_height - i][x + power_width + i] = i == 0 ? '√' : '/'
      end
      (0...@base.width).each do |i|
        board[y - @base.asc_height - 1][x + power_width + @base.height + i] = '_'
      end
      @base.draw_to(board, x + power_width + @base.height, y)
    end
  end

  class Parser
    def initialize
      @rules = {
        'frac' => lambda {|top, bottom| Fraction.new(top, bottom) },
        'sqrt' => lambda {|base|        Radical.new(base) },
        'root' => lambda {|power, base| Radical.new(base, power) },
        'br'   => lambda {|content|     Brackets.new(content) },
        'int'  => lambda {|l, h, base|  Integral.new(base, l, h) },
        'pi'   => lambda {              Text.new('π') }
      }
    end

    def use_rule(name, groups)
      @rules[name].call(*groups)
    end

    def parse_group(str)
      things = []
      until !str || str.empty? || str[0] == '}'
        if str[0] == '\\'
          str = str[1..-1]
          id = /^[-A-Za-z]+/.match(str)[0]
          str = str[id.length..-1]
          groups = []
          while str && !str.empty? && str[0] == '{'
            str, group = self.parse_group(str[1..-1])
            str = str[1..-1]
            groups << group
          end
          things << self.use_rule(id, groups)
        elsif str[0] == '^' || str[0] == '_'
          bits = {}
          while str && !str.empty? && (str[0] == '^' || str[0] == '_')
            bit_char = str[0]
            str, bit = self.parse_group(str[2..-1])
            str = str[1..-1]
            bits[bit_char] = bit
          end
          base = things.pop
          things << Script.new(base, bits['_'], bits['^'])
        else
          text = /^[^\\_^}]+/.match(str)[0]
          str = str[text.length..-1]
          things << Text.new(text)
        end
      end
      return [str, things.length > 0 ? Container.new(things) : nil]
    end
  end
end

str, c = Equations::Parser.new.parse_group(gets.chomp)
c.to_lines.each {|line| puts line }
