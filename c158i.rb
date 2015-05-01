# reddit.com/r/DailyProgrammer
# Solution to Challenge #158 (Intermediate): The ASCII Architect, pt. 1
# I herd u liek spaghetti

input, output, longest = gets.chomp.split(''), [], 0
while input.any?
  output.unshift input[0] =~ /\d/ ?
    (' ' * input.shift.to_i + '++__***---'[0, input.shift.ord - 'a'.ord + 1]) :
    '++__***---   '[0, input.shift.ord - 'a'.ord + 1]
  longest = output[0].length if output[0].length > longest
end
output.map{|s| s.reverse.rjust(longest, ' ').split('')}.reverse.transpose.map{|s| s.join}.each {|s| puts s}