$stdout.sync = true
len = ARGV[0].to_i

words = File.read("wordlist.txt").split("\n").select { |w| w.length == len }

last_word = nil

len.times do
  mask = $stdin.gets.chomp
 
  last_word = words.sample
  puts last_word
  
  errors = $stdin.gets.chomp
  
  errors.split('').each_with_index do |c, i|
    # exclude words not matching goog guesses
    words.reject! { |w| c == 'O' && w[i] != last_word[i] }
  
    # exclude words not containing misplaced letters
    words.reject! { |w| c == '?' && w.index(last_word[i]).nil? }
    
    # exclude words containing wrong letters
    words.reject! { |w| c == 'X' && !w.index(last_word[i]).nil? }
  end
end
