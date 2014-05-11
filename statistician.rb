$stdout.sync = true
len = ARGV[0].to_i

words = File.read("wordlist.txt").split("\n").select { |w| w.length == len }

# function to find good words in the list
def good_word(wordlist)
  # letter frequency
  freqs = Hash.new { |h,k| h[k] = 0 }
  wordlist.each do |w|
    w.chars.each { |c| freqs[c] += 1 }
  end

  # score = number of unique chars X sum of letter frequencies
  wordlist.max_by do |w|
    chars = w.chars.to_a.uniq
    chars.length * chars.map{|c| freqs[c]}.inject{|sum,n| sum + n}
  end
end

5.times do
  guess = good_word(words)

  puts guess
  
  result = $stdin.gets.chomp
  
  break if result =~ /^O+$/
  
  # exclude last guess
  words.delete(guess)
  
  misplaced_letters = []
  result.chars.each_with_index do |c, i|
    misplaced_letters << guess[i] if c == '?'
  
    # exclude words not matching good guesses
    words.reject! { |w| c == 'O' && w[i] != guess[i] }
  
    # exclude words not containing misplaced letters
    words.reject! { |w| c == '?' && w.index(guess[i]).nil? }
    
    # exclude words containing wrong letters unless this letter has also been misplaced
    words.reject! { |w| c == 'X' && !w.index(guess[i]).nil? && !misplaced_letters.include?(guess[i]) }
  end
end
