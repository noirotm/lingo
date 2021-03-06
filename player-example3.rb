$stdout.sync = true
len = ARGV[0].to_i

words = File.read("wordlist#{len}.txt").split("\n")

5.times do
  # we need a good word to guess, namely one with great letter
  # variety so we get more meaningful information
  guess = words.max_by { |w| w.chars.to_a.uniq.length }

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
