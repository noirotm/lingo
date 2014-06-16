require 'rbconfig'

PLAYERS = File.read("players.txt").split("\n")
LENGTHS = 4..13
ROUNDS = 100

is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
GAME_ENGINE = is_windows ? 'lingo.exe' : './lingo'

print "\t\t"
wordlist = File.read("wordlist.txt").split("\n")
words = {}
LENGTHS.each do |l|
  print "\t#{l}"
  words[l] = wordlist.select { |w| w.length == l }.sample(ROUNDS)
end
puts "\tTotal"

rankings = []
PLAYERS.each do |player|
  print player
  player_score = 0
  LENGTHS.each do |n|
    length_score = 0
    words[n].each do |word|
      output = `#{GAME_ENGINE} -word "#{word}" -player "#{player}"`
      m = output.split("\n")[-1].match(/(\d+) \/ (\d+)/)
      length_score += m[1].to_i unless m.nil?
    end
    print "\t#{length_score}"
    player_score += length_score
  end
  puts "\t#{player_score}"
  rankings.push([player, player_score])
end

puts
puts "** Rankings **"

rankings.sort_by{|a| a[1]}.reverse.each_with_index do |r, i|
  puts "#{i+1}: #{r[0]} (#{r[1]})"
end
