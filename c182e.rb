#!/usr/bin/env ruby
# /r/DailyProgrammer Challenge 182e: The Column Conundrum

words = []
columns, column_width, space_width = gets.chomp.split(' ').map {|s| s.to_i}

while (line = gets; line != nil && line.chomp.length > 0)
  words += line.chomp.split(' ')
end

lines = []
while words.count > 0
  line = ""
  loop do
    new_line = "#{line} #{words[0]}".strip
    break if new_line.length >= column_width || words.count == 0
    words.shift
    line = new_line
  end
  lines.push line.ljust(column_width, ' ')
end

total_line_count = (lines.length / columns).ceil + 1

(0..total_line_count).each do |index|
  puts (index...lines.length)
    .step(total_line_count + 1)
    .map {|line_index| lines[line_index]}
    .join (' ' * space_width)
end