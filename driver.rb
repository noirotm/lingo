require 'rbconfig'

PLAYERS = [
  "ruby player-example.rb",
  "ruby player-example2.rb",
  "ruby player-example3.rb"
]
LENGTHS = 4..13
ROUNDS = 1

is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
GAME_ENGINE = is_windows ? 'lingo.exe' : './lingo'

print "\t\t"
LENGTHS.each { |l| print "\t#{l}" }
puts "\tTotal"

rankings = []
PLAYERS.each do |player|
  print player
  player_score = 0
  LENGTHS.each do |n|
    output = `#{GAME_ENGINE} -rounds #{ROUNDS} -length #{n} -player "#{player}"`
    m = output.split("\n")[-1].match(/(\d+) \/ (\d+)/)
    score = m[1].to_i
    print "\t#{score}"
    player_score += score
  end
  puts "\t#{player_score}"
  rankings.push([player, player_score])
end

puts
puts "** Rankings **"

rankings.sort_by{|a| a[1]}.reverse.each_with_index do |r, i|
  puts "#{i+1}: #{r[0]} (#{r[1]})"
end
