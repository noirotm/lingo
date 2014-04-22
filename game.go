package main

import (
	"bufio"
	"bytes"
	"fmt"
	"os/exec"
	"strconv"
	"strings"
)

// LingoGame represents the game itself
type LingoGame struct {
	wordLength    int
	wordList      WordList
	playerProgram string
	arguments     []string
}

// NewGame creates a new Lingo game
func NewGame(wordLength int, wordList WordList, playerProgram string) *LingoGame {
	cmdLine := strings.Fields(playerProgram)
	program := cmdLine[0]
	arguments := cmdLine[1:len(cmdLine)]
	arguments = append(arguments, strconv.Itoa(wordLength))

	return &LingoGame{
		wordLength:    wordLength,
		wordList:      wordList,
		playerProgram: program,
		arguments:     arguments,
	}
}

func checkWord(word string, guess string) string {
	var buffer bytes.Buffer
	for i := 0; i < len(guess); i++ {
		if word[i] == guess[i] {
			// exact guess
			buffer.WriteByte('O')
		} else if strings.IndexByte(word, guess[i]) != -1 {
			// byte in string at another position
			buffer.WriteByte('?')
		} else {
			// byte not present
			buffer.WriteByte('X')
		}
	}
	return buffer.String()
}

func (p *LingoGame) PlayRound() (int, error) {
	// initialize round
	currentWord := p.wordList.RandomWord()
	wordMask := bytes.Repeat([]byte("."), p.wordLength)

	fmt.Println("Starting new round, word is", currentWord)

	// start player program
	player := exec.Command(p.playerProgram, p.arguments...)
	stdin, err := player.StdinPipe()
	if err != nil {
		return 0, err
	}
	stdout, err := player.StdoutPipe()
	if err != nil {
		return 0, err
	}
	if err := player.Start(); err != nil {
		return 0, err
	}

	// round loop, as many attempts as the word length
	in := bufio.NewScanner(stdout)
	var roundAttempts int
	score := 0
	for roundAttempts = 0; roundAttempts < p.wordLength; roundAttempts++ {
		// send word mask
		stdin.Write(wordMask)
		stdin.Write([]byte("\n"))
		fmt.Println("Sent: ", string(wordMask))

		// get word guess
		if !in.Scan() {
			stdin.Close()
			stdout.Close()
			player.Wait()
			return 0, in.Err()
		}
		guess := in.Text()
		fmt.Println("Got:  ", guess)

		// check whether word is valid, if not, send a full error response
		if len(guess) == 0 || !p.wordList.Contains(guess) {
			stdin.Write([]byte(strings.Repeat("X", p.wordLength)))
			stdin.Write([]byte("\n"))
			fmt.Println("Sent: ", strings.Repeat("X", p.wordLength))
			continue
		}

		// check letter positions and send guess mask
		attemptMask := checkWord(currentWord, guess)

		// update word mask with found letters
		for i, b := range []byte(attemptMask) {
			if b == 'O' {
				wordMask[i] = currentWord[i]
			}
		}

		stdin.Write([]byte(attemptMask))
		stdin.Write([]byte("\n"))
		fmt.Println("Sent: ", string(attemptMask))

		// break if word has been found
		// calculate score, we get points only if mask is equal to the word to guess
		if currentWord == string(wordMask) {
			score = 10 * (p.wordLength - roundAttempts)
			fmt.Println("Round won with score", score)
			break
		}
	}

	// wait for program exit
	stdin.Close()
	stdout.Close()
	player.Wait()

	if score == 0 {
		fmt.Println("Round lost")
	}

	return score, nil
}
