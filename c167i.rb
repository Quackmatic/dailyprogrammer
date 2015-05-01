def line(fn, ln, *grades)
  sorted_grades = grades.map {|g| g.to_i}.sort {|g, h| g <=> h}
  final = (sorted_grades.inject(:+) / 5.0).round
  grade = ['F', 'D', 'C', 'B', 'A', 'A'][[0, final / 10 - 5].max]
  grade += (final % 20 < 3 && grade != 'F' ? '-' :
           (final % 20 > 16 && !(['A', 'F'].include? grade) ? '+' : ' '))
  {:last => ln.gsub('_', ' '), :first => fn.gsub('_', ' '), :grade => final, :string =>
    "(#{final.to_s.rjust(2, '0')}%) (#{grade}): #{sorted_grades.map {|g| '%2d' % g}.join ' '}"}
end

entries = []
until (entries.length > 1 && entries.last.length == 0)
  entries.push gets.chomp.split(' ').reject{|f| f.empty?}
end

entries.pop

entries.map! {|e| line(*e)}.sort {|f, g| g[:grade] <=> f[:grade]}.each do |e|
  puts e[:last].rjust( entries.map {|f| f[:last].length} .inject {|f, g| [f, g].max}, ' ') + ' ' +
       e[:first].rjust(entries.map {|f| f[:first].length}.inject {|f, g| [f, g].max}, ' ') + ' ' +
       e[:string]
end