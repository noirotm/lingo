package main

import (
	"flag"
	"fmt"
)

var (
	rounds     int
	player     string
	wordLength int
)

func init() {
	flag.IntVar(&rounds, "rounds", 1, "number of rounds to play")
	flag.IntVar(&rounds, "r", 1, "number of rounds to play")

	flag.IntVar(&wordLength, "length", 5, "word length")
	flag.IntVar(&wordLength, "l", 5, "word length")

	flag.StringVar(&player, "player", "", "player program to execute")
	flag.StringVar(&player, "p", "", "player program to execute")
}

func main() {
	flag.Parse()

	if rounds <= 0 || len(player) == 0 || wordLength <= 0 {
		flag.Usage()
		return
	}

	wordList, err := LoadWordList(wordLength)
	if err != nil {
		panic(err)
	}

	game := NewGame(wordLength, wordList, player)

	totalScore := 0

	for i := 0; i < rounds; i++ {
		score, err := game.PlayRound()
		if err != nil {
			panic(err)
		}

		totalScore += score
	}

	fmt.Println("\nTotal score is", totalScore, "/", wordLength*wordLength)
}
