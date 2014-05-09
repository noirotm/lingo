# Guess the word (aka Lingo) #

This is a programming challenge for [http://codegolf.stackexchange.com/](http://codegolf.stackexchange.com/questions/26858/guess-the-word-aka-lingo).

The following programs are available:

- `lingo`: the game engine, which can be compiled with a [Go 1.2](http://golang.org/) installation, using the `go build` command in the checked out repository.
- [pit.rb](pit.rb): a ruby script used to evaluate player programs submitted on the website.
- [stats.rb](stats.rb): a script showing a few statistics for the included word list.
- `player-example*.rb`: test player program implementations of various strengths (although rather naive).

The file [wordlist.txt](wordlist.txt) is an extensive list of english words to be used as a reference by the game engine and implementations.

## Running the game engine ##

The `lingo` program accepts a few command line arguments:

- `-program` the player program to run
- `-length` the word length
- `-rounds` the number of rounds to play
- `-word` a specific word to guess, forces only one round to be played

Examples:

    ./lingo -program "ruby player-example.rb" -length 10 -rounds 5

This will display the detail of words and guesses, as well as each round's score and the total score.

    ./lingo -program "./my_test_player" -word "tortoise"

Just as above, but only one round will be played with the given word to be guessed.

## Evaluating an entry ##

Edit the `pit.rb` file to add your entry.

Your program will be run in the current directory and will be given the length of the word to guess as first argument on the command line.

Be careful to flush your output to `STDOUT`, otherwise the game engine might wait for guesses indefinitly.

## Found a bug ? ##

Post an issue here or a pull request, including updating [game_test.go](game_test.go) to provide a reproductible test case if possible.
