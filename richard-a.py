import sys
import random

# Get the wordlist
def get_wordlist():
    file = open("wordlist.txt")
    return file.read().split("\n")

# Pick a random word from the list
def pick_word(length):
    words = get_wordlist()

    filtered_words = filter_words_by_length(words, length)

    index = random.randint(0, len(filtered_words) - 1)

    return filtered_words[index]


# Filter words by the given length
def filter_words_by_length(words, length):
    filtered_words = []

    for word in words:
        if word.__len__() == length:
            filtered_words.append(word)

    return filtered_words

# Resolve the guess
def resolve_guess(guess, selected_word):

    # The string that will show (in)correct letters
    result = []

    # If the given length doesn't match, it's a mistake by default
    if len(guess) != len(selected_word):
        return "X" * len(selected_word)

    guess_letters = list(guess)
    selected_word_letters = list(selected_word)
    correct_positions = []

    # First, try to find the correct letters
    for i, letter in enumerate(guess_letters):
        if guess_letters[i] == selected_word_letters[i]:
            correct_positions.append(i)
            result.append("O")
        else:
            result.append("X")

    # Now for all incorrect letters, see if any of them are IN the word somewhere
    for i, letter in enumerate(guess_letters):
        if result[i] == "X":
            result_char = check_if_wrong_letter_in_word(letter, guess_letters, selected_word_letters, i, correct_positions)
            result[i] = result_char

    return ''.join(result)

# Check if the given letter is not already guessed in the word
def check_if_wrong_letter_in_word(letter, guess_letters, word_letters, index, guessed_positions):

    in_word = letter_count_in_word(letter, word_letters)
    in_guess = letter_count_in_word(letter, guess_letters)

    if in_guess == 1:
        if in_word == 1 and letter in word_letters and index not in guessed_positions:
            return "?"
    else:
        if in_word > 1 and letter in word_letters and index not in guessed_positions:
            return "?"

    return "X"

# Check if the given letter is in the word multiple times
def letter_count_in_word(letter, word_letters):

    times = 0

    for word_letter in word_letters:
        if word_letter == letter:
            times += 1

    return times


## START MAIN PROGRAM
MAX_TURNS = 5
cur_turn = 1
word_guessed = False

# Get word length
try:
    selected_length = int(sys.argv[1])
except IndexError:
    sys.exit("Not enough arguments; please provide a second argument as a number.")
except ValueError:
    sys.exit("Given input is not a number.")

# Pick a word
word = pick_word(selected_length)

print("A {0} letter word has been chosen, please guess the word.".format(selected_length))

# Game loop
while cur_turn <= MAX_TURNS:
    guess = input().lower()

    answer = resolve_guess(guess, word)

    print(answer + "\n")

    # Increment turns
    cur_turn += 1


if word_guessed:
    print("You correctly guess the word {0}! :)".format(word))
else:
    print("Damn... you didn't guess the word {0}. :(".format(word))