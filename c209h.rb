class Checker
  def initialize(words)
    @words = words.map {|w| w.chomp.downcase}.select {|w| w.length > 1 || ['a', 'i'].include?(w)}
  end

  def resolve_part(sentence, accumulator)
    if sentence.length > 0
      sentence = sentence.downcase.gsub(/[^a-z]/, '')
      possible = @words.select {|w| sentence.start_with? w}
      unless possible.empty?
        possible.map {|w| resolve_part(sentence[w.length .. -1], accumulator.clone.push(w))}
      else
        @words.each do |w|
          if w.start_with? sentence
            return "#{accumulator.join(' ').upcase} #{w}?"
          end
        end
        []
      end
    else
      accumulator.join(' ').upcase
    end
  end

  def resolve(sentence)
    sentences = [resolve_part(sentence, [])].flatten.compact
    if sentences.any? {|s| s[-1] != '?'}
      sentences.reject {|s| s[-1] == '?'}
    else
      sentences
    end
  end
end

class Board
  attr_reader :width, :height

  def initialize(width, height)
    @width, @height = width, height
    self.set_board(Array.new(width) {Array.new(height) {' '}})
  end

  def in_bounds?(x, y)
    x >= 0 && y >= 0 && x < @width && y < @height
  end

  def [](x, y)
    if self.in_bounds?(x, y)
      @board[x][y]
    else
      nil
    end
  end

  def []=(x, y, c)
    if self.in_bounds?(x, y)
      @board[x][y] = c
    end
  end

  def set_board(board)
    if board.length == @width &&
       board[0].length == @height
      board.each do |col|
        if col.length != board[0].length 
          raise "Non-uniform column size in board"
        end
      end
      @board = board
    else
      raise IndexError("Wrong board size (#{@width}x#{@height} " +
                       "expected, #{board.length}x#{board[0].length} given")
    end
  end

  def self.from_lines(lines)
    grid = lines.map{|s| s.chars}.transpose
    board = Board.new(grid.length, grid[0].length)
    board.set_board(grid)
    board
  end
end

if ARGV.empty?
  puts "Please specify the path to a word list as an argument."
  exit
end

def unpack_partial(board, checker, sentence, sentence_resolved, x, y, seen)
  if board.in_bounds?(x, y) && !seen.include?([x, y])
    new_sentence = sentence + board[x, y]
    puts "(#{x}, #{y}): #{new_sentence}"
    new_sentence_resolved = checker.resolve(new_sentence)
    if new_sentence_resolved.length > 0
      new_seen = seen.clone.push([x, y])
      if new_seen.length == board.width * board.height
        new_sentence_resolved
      else
        [[x - 1, y], [x + 1, y], [x, y - 1], [x, y + 1]].each do |c|
          value = unpack_partial(
            board, checker,
            new_sentence,
            new_sentence_resolved,
            *c,
            new_seen)
          return value if value != nil
        end
        nil
      end
    else
      nil
    end
  else
    nil
  end
end

def unpack(board, checker, x, y)
  unpack_partial(board, checker, '', [], x, y, [])
end

line_count, x, y = *STDIN.gets.chomp.split(' ').map {|s| s.to_i}
x -= 1
y -= 1
board = Board.from_lines(line_count.times.map {STDIN.gets.chomp.gsub(/ /, '')})
checker = Checker.new(File.readlines(ARGV[0]))
solutions = unpack(board, checker, x, y)

if solutions.empty?
  puts "No solution."
else
  solutions.each do |s|
    puts "Solution: #{s}"
  end
end
