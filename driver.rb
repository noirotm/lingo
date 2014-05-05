PLAYERS = [
  "ruby player-example.rb",
  "ruby player-example2.rb",
  "ruby player-example3.rb"
]
LENGTHS = 4..13
ROUNDS = 100

print "\t\t"
LENGTHS.each { |l| print "\t#{l}" }
puts "\tTotal"

PLAYERS.each do |player|
  print player
  player_score = 0
  LENGTHS.each do |n|
    output = `lingo.exe -rounds #{ROUNDS} -length #{n} -player "#{player}"`
    m = output.split("\n")[-1].match(/(\d+) \/ (\d+)/)
    score = m[1].to_i
    print "\t#{score}"
    player_score += score
  end
  puts "\t#{player_score}"
end
