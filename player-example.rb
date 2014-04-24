$stdout.sync = true
len = ARGV[0].to_i

words = File.read("wordlist.txt").split("\n").select { |w| w.length == len }

len.times do
  guess = words.sample
  puts guess
  
  result = $stdin.gets.chomp
  result.split('').each_with_index do |c, i|
    # exclude words not matching good guesses
    words.reject! { |w| c == 'O' && w[i] != guess[i] }
  end
end
