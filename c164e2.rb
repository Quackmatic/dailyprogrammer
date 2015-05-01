# gravitational constant
G = 6.67e-11

class Planet
  attr_reader :radius, :density
  
  def initialize(radius, density)
    @radius = radius
    @density = density
  end
  
  def volume
    # 4/3 * pi * r³
    return (4 * Math::PI * radius ** 3) / 3
  end
  
  def mass
    return self.volume * self.density
  end
  
  def force_on(mass, dist)
    # this is just the gravitational formula described in the post
    G * self.mass * mass / (dist ** 2)
  end
end

planets = {}

obj_mass = gets.chomp.to_i
no_of_planets = gets.chomp.to_i
no_of_planets.times do
  planet = gets.chomp.split(',').map {|n| n.strip}
  planets[planet[0]] = Planet.new(planet[1].to_i, planet[2].to_i)
end

planets.each do |k, v|
  puts "#{k}: #{'%.3f' % v.force_on(obj_mass, v.radius)}"
end