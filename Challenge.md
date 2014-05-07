# Guess the word (aka Lingo) #

The goal of this challenge is to write a program able to guess a word in the smallest possible number of attempts.
It is based on the concept of the Lingo TV show ([http://en.wikipedia.org/wiki/Lingo_(U.S._game_show)](http://en.wikipedia.org/wiki/Lingo_(U.S._game_show))).

## Rules ##

Given a word length passed as the first argument on its command line, the player program disposes of **five** attempts to guess the word by writing a guess on its standard output followed by a single `\n` character. 

After a guess is made, the program receives a string on its standard input, also followed by a single `\n` character.

The string has the same length as the word to guess and is comprised of a sequence of the following characters:

- `X`: which means that the given letter is not present in the word to guess
- `?`: which means that the given letter is present in the word to guess, but at another location
- `O`: which means that the letter at this location has been correctly guessed

For example, if the word to guess is `dents`, and the program sends the word `dozes`, it will receive `OXX?O` because `d` and `s` are correct, `e` is misplaced, and `o` and `z` are not present.

Be careful that if a letter is present more times in the guessing attempt than in the word to guess, it will **not** be marked as `?` and `O` more times than the number of occurences of the letter in the word to guess.
For example, if the word to guess is `cozies` and the program sends `tosses`, it will receive `XOXXOO` because there is only one `s` to locate.

Words are chosen from an english word list. If the word sent by the program is not a valid word of the correct length, the attempt is considered as an automatic failure and only `X`'s are returned.  
The player program should assume that a file named `wordlist.txt` and containing one word per line is present in the current working directory, and can be read as necessary.  
Guesses should only be comprised of alphabetic low-case characters (`[a-z]`).  
No other network or file operations are allowed for the program.

The game ends when a string only comprised of `O` is returned or after the program has made 5 attempts and was not able to guess the word.

## Scoring ##

The score of a game is given by the given formula:

    score = 100 * (6 - number_of_attempts)

So if the word is correctly guessed on the first try, 500 points are given. The last try is worth 100 points.

Failure to guess the word grants zero points.

## The pit ##

Player programs will be evaluated by trying to have them guess **100** random words for each word length between 4 and 13 characters inclusively.

The winning program, and accepted answer, will be the one to reach the highest score.

Programs will be run in an Ubuntu virtual machine, using the code at [https://github.com/noirotm/lingo](https://github.com/noirotm/lingo). Implementations in any language are accepted as long as reasonable instructions to compile and/or run them are provided.

I'm providing a few test implementations in ruby in the git repository, feel free to take inspiration from them.

This question will be periodically updated with rankings for published answers so challengers can improve their entries.

The official final evaluation will take place on the **1st of July**.

[tag:king-of-the-hill] [tag:word] [tag:game]