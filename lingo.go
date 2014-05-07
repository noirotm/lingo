package main

import (
	"flag"
	"fmt"
)

var (
	rounds     int
	player     string
	wordLength int
	word       string
)

func init() {
	flag.IntVar(&rounds, "rounds", 1, "number of rounds to play")
	flag.IntVar(&wordLength, "length", 5, "word length")
	flag.StringVar(&player, "player", "", "player program to execute")
	flag.StringVar(&word, "word", "", "optional word to guess, forces only one round and word length")
}

func main() {
	flag.Parse()

	// Force word to guess
	if len(word) > 0 {
		rounds = 1
		wordLength = len(word)
	}

	if rounds <= 0 || len(player) == 0 || wordLength <= 0 {
		flag.Usage()
		return
	}

	wordList, err := LoadWordList(wordLength)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	if len(word) > 0 && !wordList.Contains(word) {
		fmt.Println("Error: Unknown word")
		return
	}

	game := NewGame(wordLength, wordList, player)

	totalScore := 0

	for i := 0; i < rounds; i++ {
		var score int
		var err error

		if len(word) > 0 {
			score, err = game.PlayRound(word)
		} else {
			score, err = game.PlayRandomRound()
		}

		if err != nil {
			fmt.Println("Error:", err)
			return
		}

		totalScore += score
	}

	fmt.Println("\nTotal score:", totalScore, "/", 100*MAX_ATTEMPTS*rounds)
}
