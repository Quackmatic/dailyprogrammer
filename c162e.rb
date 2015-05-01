def decompress(chunks, dict)
  delimiter, next_delimiter = '', ' '
  output = ''
  chunks.each do |ch|
    case ch
      when /[0-9]\^/
        output += delimiter + dict[ch.to_i].capitalize
      when /[0-9]!/
        output += delimiter + dict[ch.to_i].upcase
      when /[0-9]/
        output += delimiter + dict[ch.to_i]
      when /[rR]/
        output += delimiter + "\n"
        next_delimiter = ''
      when /[eE]/
        output += delimiter # needed for any punctuation at the end of a line
        break               # exit the loop
      when /\-/
        next_delimiter = '-'
      when /[\.,\?!;:]/
        next_delimiter = ch + next_delimiter
      else
        puts 'Bad chunk: ' + ch
    end
    delimiter = next_delimiter
    next_delimiter = ' '
  end
  return output
end

dict_size = gets.chomp.to_i
dict = Array.new(dict_size) { gets.chomp.downcase }

chunks = []
loop do
  input_chunks = gets.chomp.split ' '
  chunks += input_chunks
  break if input_chunks.last == 'E'
end

puts decompress(chunks, dict)