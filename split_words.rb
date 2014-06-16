words = File.read("wordlist.txt").split("\n")
words.each do |w|
  if w.length >= 4 && w.length <= 13
    IO.write("wordlist#{w.length}.txt", "#{w}\n", { :mode => "a"})
  end
end