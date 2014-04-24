PLAYERS = [
  "ruby player-example.rb",
  "ruby player-example2.rb",
  "ruby player-example3.rb"
]
LENGTHS = 4..13
ROUNDS = 30

print "\t\t"
LENGTHS.each { |l| print "\t#{l}" }
puts "\tAverage"

PLAYERS.each do |player|
  print player
  player_score = 0
  LENGTHS.each do |n|
    output = `lingo.exe -rounds #{ROUNDS} -length #{n} -player "#{player}"`
    m = output.split("\n")[-1].match(/(\d+) \/ (\d+)/)
    score = (100 * m[1].to_f / m[2].to_f).round(2)
    print "\t#{score}"
    player_score += score
  end
  puts "\t#{(player_score / LENGTHS.count.to_f).round(2)}"
end
