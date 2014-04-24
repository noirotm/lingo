$stdout.sync = true
len = ARGV[0].to_i

words = File.read("wordlist.txt").split("\n").select { |w| w.length == len }

len.times do
  line = $stdin.gets.chomp
  words.select! { |w| !Regexp.new(line).match(w).nil? }
  puts words.sample
  line = $stdin.gets.chomp
end
