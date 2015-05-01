def tokenize(word, dict)
  return word[0] if ['-', 'R*'].include? word
  token = (dict.find_index word.downcase.gsub(/[.,\?!;:]/, '')).to_s
  (dict << word.downcase.gsub(/[.,\?!;:]/, '');
    token = (dict.length - 1).to_s) unless token.length > 0
  case word
    when /^[a-z]*[.,\?!;:]?$/; # nothing
    when /^[A-Z][a-z]*[.,\?!;:]?$/; token += '^'
    when /^[A-Z]*[.,\?!;:]?$/; token += '!'
    else; puts "Error! Invalid case or punctuation in word #{word}."; abort
  end
  word.match(/[.,\?!;:]$/) {|m| word = word[0..(word.length - 1)]; token += ' ' + m[0]}
  (puts "Error! Invalid punctuation #{word[-1]}."; abort) unless word[-1].match /[a-zA-Z.,\?!;:]/
  return token
end

def compress(data)
  dict = []
  word_list = data.lines.map do |l|
     (l + ' R*')
      .chomp
      .gsub(/\-/, ' - ')
      .split(' ')
  end.flatten.map do |w|
    tokenize(w, dict)
  end
  word_data = word_list
    .each_slice(24)
    .to_a
    .map {|ws| ws.join ' '}
    .join "\n"
  return "#{dict.length}\n#{dict.join "\n"}\n#{word_data} E"
end

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

(puts 'Please specify 3 arguments.'; abort) unless ARGV.length == 3

if ARGV[0] == '-c'
  File.open(ARGV[1], 'r') do |f|
    File.open(ARGV[2], 'w') do |g|
      g.syswrite compress f.gets nil
    end
  end
elsif ARGV[0] == '-d'
  File.open(ARGV[1], 'r') do |f|
    File.open(ARGV[2], 'w') do |g|
      dict_size = f.gets.chomp.to_i
      dict = Array.new(dict_size) { f.gets.chomp.downcase }
      chunks = []
      loop do
        input_chunks = f.gets.chomp.split ' '
        chunks += input_chunks
        break if input_chunks.last == 'E'
      end
      g.syswrite decompress(chunks, dict)
    end
  end
else
  puts "Invalid flag: #{ARGV[0]}"
end