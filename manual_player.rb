len = ARGV[0].to_i

words = File.read("wordlist.txt").split("\n")
words.select! { |w| w.length == len }

len.times do
  line = STDIN.gets.chomp
  
  words.select! { |w| !Regexp.new(line).match(w).nil? }

  puts words.sample
  STDOUT.flush

  line = STDIN.gets.chomp
end
