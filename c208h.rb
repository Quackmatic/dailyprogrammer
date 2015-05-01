module Machine
	class Tape
		def initialize(alphabet, initial='')
			@alphabet = ('_' + alphabet).chars.uniq.join ''
			@head     = 0
			@tape     = Hash.new
			initial.each_char do |c|
				self.write c
				self.right
			end
			@head = 0
		end

		def in_alphabet?(c)
			@alphabet.include? c
		end

		def read
			@tape[@head] || '_'
		end

		def write(c)
			@tape[@head] = c
			raise Exception.new("Symbol #{c} is not in the alphabet (#{@alphabet}) of this tape.") unless self.in_alphabet? c
		end

		def left
			@head -= 1
		end

		def right
			@head += 1
		end

		def display
			keys = @tape.delete_if {|i, s| s == '_' && i != 0}.keys
			range = (keys.min .. keys.max)
			puts range.map{|i| @tape[i] || '_' }.join ''
			puts range.map{|i| i == 0     ? '|' :
									       i == @head ? '^' : 
												              ' '}.join ''
		end
	end

	class Rule
		def initialize(state_from, state_to, symbol_before, symbol_after, direction)
			raise Exception.new("Unknown direction #{direction.to_s}.") unless [:left, :right].include? direction
			@state_from    = state_from
			@state_to      = state_to
			@symbol_before = symbol_before
			@symbol_after  = symbol_after
			@direction     = direction
		end

		def valid_for?(machine)
			machine.tape.in_alphabet?(@symbol_before) &&
				machine.tape.in_alphabet?(@symbol_after) &&
				machine.has_state?(@state_from) &&
				machine.has_state?(@state_to)
		end

		def can_apply?(machine)
			machine.tape.read == @symbol_before &&
				machine.state == @state_from
		end

		def apply(machine)
			machine.state = @state_to
			machine.tape.write @symbol_after

			case @direction
			when :left
				machine.tape.left
			when :right
				machine.tape.right
			end
		end

		def self.from_string(s)
			if s =~ /([A-Za-z0-9]+) +([^ ]) += +([A-Za-z0-9]+) +([^ ]) +([<>])/
				Rule.new($1, $3, $2, $4, { '<' => :left, '>' => :right }[$5])
			else
				raise Exception.new("Badly formatted rule string: #{s}")
			end
		end
	end

	class Machine
		attr_reader :tape, :accepting_state
		
		def initialize(states, initial_state, accepting_state, tape)
			@tape = tape
			@states = states.uniq
			@state = initial_state
			@accepting_state = accepting_state
		end

		def has_state?(s)
			@states.include? s
		end

		def state
			@state
		end

		def state=(s)
			raise Exception.new("Unknown state #{s}.") unless self.has_state? s
			@state = s
		end

		def done?
			self.state == self.accepting_state
		end
	end
end

alphabet = gets.chomp
states = gets.chomp.split ' '
initial_state, accepting_state = gets.chomp, gets.chomp
initial_tape = gets.chomp
rules = []

machine = Machine::Machine.new(
	states,
	initial_state,
	accepting_state,
	Machine::Tape.new(alphabet, initial_tape))

while line = gets
	rule = Machine::Rule.from_string line.chomp
	raise Exception.new("Invalid rule for the given machine.") unless rule.valid_for? machine
	rules.push rule
end

until machine.done?
	applicable_rules = rules.select {|r| r.can_apply? machine}
	if applicable_rules.count == 0
		raise Exception.new("No rule for state (#{machine.state}, #{machine.tape.read}).")
	elsif applicable_rules.count > 1
		raise Exception.new("Multiple rules for state (#{machine.state}, #{machine.tape.read}).")
	else
		applicable_rules.first.apply machine
	end
end

machine.tape.display
