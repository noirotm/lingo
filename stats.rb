words = File.read("wordlist.txt").split("\n")

lengths = Hash.new { |h,k| h[k] = 0 }
words.each do |w|
  lengths[w.length] += 1
end

lengths.to_a.sort.each { |e| puts "#{e[0]}:\t#{e[1]}" }

puts

freqs = Hash.new { |h,k| h[k] = 0 }
words.each do |w|
  w.chars.each { |c| freqs[c] += 1 }
end

freqs.to_a.sort.each { |e| puts "#{e[0]}:\t#{e[1]}" }