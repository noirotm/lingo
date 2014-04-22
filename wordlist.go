package main

import (
	"bufio"
	"fmt"
	"math/rand"
	"os"
	"strings"
	"time"
)

// Wordlist represents a list of words with a given character length.
type WordList []string

// LoadWordList loads words from the given file, one word per line
func LoadWordList(wordLength int) (WordList, error) {
	f, err := os.Open("wordlist.txt")
	if err != nil {
		return nil, err
	}

	rand.Seed(time.Now().UnixNano())

	wordList := make([]string, 0, 1024)
	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		word := strings.ToLower(scanner.Text())
		if len(word) == wordLength {
			wordList = append(wordList, word)
		}
	}
	if err := scanner.Err(); err != nil {
		return nil, err
	}

	fmt.Println(wordList)

	return wordList, err
}

// RandomWord returns a random word in the list
func (p WordList) RandomWord() string {
	idx := rand.Intn(len(p))
	return p[idx]
}

// Contains returns a boolean indicating whether the given string is present in the list
func (p WordList) Contains(word string) bool {
	for _, w := range p {
		if w == word {
			return true
		}
	}
	return false
}
