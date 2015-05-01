# calculates the angular frequency from a planet's period. the angular
# frequency (omega) of a time period p is such that a function like
# sin(omega * t) has a period p with respect to t
def omega(p)
  p.clone.merge({omega: (2 * Math::PI / p[:period])})
end

# calculates the position of a planet from its radius and a given time t
# by finding its angle from the starting position (omega * t) and then
# finding the co-ordinates at that angle on a circle describing its orbit
# (ie. with the same radius as its orbit)
# the circle is described by the parametric equation:
# x=radius*cos(omega*t)
# y=radius*sin(omega*t)
def position(p, t)
  [p[:radius] * Math.cos(p[:omega] * t), p[:radius] * Math.sin(p[:omega] * t)]
end

# gets the angle of the bearing from planet p to planet q at time t
# for example, if you are on planet p looking at an angle of 0,
# how much must you turn in order to face planet q?
def angle_to(p, q, t)
  pp, pq = position(p, t), position(q, t)
  Math.atan((pq[1] - pp[1]) / (pq[0]-pp[0]))
end

# gets the shortest angle distance between two angles
# eg. the angles 350 degrees and 10 degrees have a shortest distance
# of 20 degrees, because at 360 degrees the angle 'wraps around' to zero
def angle_diff(a, b)
  return ((b - a + Math::PI) % (2 * Math::PI) - Math::PI).abs
end

# works out if the planets q and r are in syzygy from p's perspective
# this is debatable, as it uses the arbitrary value of having q and r no
# more than 0.01 radians away from each other from p's perspective, but
# it's good enough for this challenge
def in_syzygy?(p, q, r, t)
  return angle_diff(angle_to(q, p, t), angle_to(q, r, t)) < 0.01
end

# inefficient way of determining if all planets are in syzygy with respect
# to each other. for example, to determine if (p, q, r, s, t) planets are
# all in sygyzy, it gets all of the combinations of three and checks if
# each combination is in syzygy:
# (p, q, r)
# (p, q, s)
# (p, q, t)
# (p, r, s) and so on
# this could probably be done better by calculating the angles of all of
# the planets to one planet, eg.:
# angle of p to t
# angle of q to t
# angle of r to t
# angle of s to t
# and ensuring all are less than a certain angle, but this becomes inacc-
# urate if t is very far away from the rest
def all_in_syzygy?(cm, t)
  return cm.combination(3).each do |cm| 
    return false unless in_syzygy?(cm[0], cm[1], cm[2], t)
  end
  true
end

# given all of the planets at time t, work out all the combinations of n
# planets which are in syzygy at that time (again via combinations...
# Ruby's standard library functions are excellent)
def n_syzygy(planets, n, t)
  planets
    .combination(n).to_a
    .select {|cm| all_in_syzygy?(cm, t)}
end

# gets all of the combinations of planets at time t that are in syzygy...
# as this calculates all of the possible combination sizes up to the length
# of the array, this can be quite slow
def syzygy(planets, t)
  (3..planets.length).to_a
    .map {|n| n_syzygy(planets, n, t)}
    .flatten(1)
end

# if planets p, q, r, and s are in sygyzy, this creates a string like
# "p-q-r-s" for printing the output
def syzygy_name(s)
  return s
    .map {|p| p[:name]}
    .join '-'
end

# solar system data, copied by hand from Wikipedia... :(
planet_data = [
  { name: 'Sun', radius: 0.000, period: 1.000 },
  { name: 'Mercury', radius: 0.387, period: 0.241 },
  { name: 'Venus', radius: 0.723, period: 0.615 },
  { name: 'Earth', radius: 1.000, period: 1.000 },
  { name: 'Mars', radius: 1.524, period: 1.881 },
  { name: 'Jupiter', radius: 5.204, period: 11.862 },
  { name: 'Saturn', radius: 9.582, period: 29.457 },
  { name: 'Uranus', radius: 19.189, period: 84.017 },
  { name: 'Neptune', radius: 30.071, period: 164.795 }
].map {|p| omega p}

# gets the time to calculate syzygies at
t = gets.chomp.to_f

puts "At T=#{t}:"
puts syzygy(planet_data, t).map {|s| syzygy_name s}.join ', '