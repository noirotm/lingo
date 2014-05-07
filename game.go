package main

import (
	"bufio"
	"bytes"
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	"strconv"
	"strings"
)

const MAX_ATTEMPTS = 5

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

// checkWord determines the letters that are placed correctly or not within the guess
func checkWord(word string, guess string) string {
	result := bytes.Repeat([]byte("X"), len(word))
	found_indexes := make(map[byte]int)

	// check for correct guesses
	for i, b := range []byte(guess) {
		if word[i] == b {
			// exact guess
			found_indexes[b] = i
			result[i] = 'O'
		}
	}

	// check for misplaced guesses
	for i, b := range []byte(guess) {
		// last index where the letter was found
		last_index, ok := found_indexes[b]
		if !ok {
			last_index = -1
		}

		if idx := strings.IndexByte(word[last_index+1:], b); idx != -1 {
			// byte in string at another position
			found_indexes[b] = idx + last_index + 1
			result[i] = '?'
		}
	}
	return string(result)
}

func writeLine(out io.Writer, line []byte) {
	out.Write(line)
	out.Write([]byte("\n"))
	fmt.Println("Sent: ", string(line))
}

// PlayRound runs the player program and plays a round till the word is found or no more attempts remain
func (p *LingoGame) PlayRound(currentWord string) (int, error) {
	fmt.Println("Starting new round, word is", currentWord)

	// start player program
	player := exec.Command(p.playerProgram, p.arguments...)
	player.Stderr = os.Stderr
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

	// wait for program exit when this function returns
	defer func() {
		stdin.Close()
		stdout.Close()
		player.Wait()
	}()

	// round loop, as many attempts as the word length
	in := bufio.NewScanner(stdout)
	var roundAttempts int
	score := 0
	for roundAttempts = 0; roundAttempts < MAX_ATTEMPTS; roundAttempts++ {
		// get word guess
		if !in.Scan() {
			readError := in.Err()
			if readError == nil {
				readError = errors.New("Player program ended unexpectedly")
			}
			return 0, readError
		}
		guess := in.Text()
		fmt.Println("Got:  ", guess)

		// check whether word is valid, if not, send a full error response
		if len(guess) == 0 || !p.wordList.Contains(guess) {
			writeLine(stdin, []byte(strings.Repeat("X", p.wordLength)))
			continue
		}

		// check letter positions and send guess mask
		attemptMask := checkWord(currentWord, guess)

		// send word mask with discovered characters
		writeLine(stdin, []byte(attemptMask))

		// break if word has been found
		// calculate score, we get points only if mask is equal to the word to guess
		if attemptMask == strings.Repeat("O", p.wordLength) {
			score = 100 * (MAX_ATTEMPTS - roundAttempts)
			fmt.Println("Round won with score", score)
			break
		}
	}

	if score == 0 {
		fmt.Println("Round lost")
	}

	return score, nil
}

// PlayRandomRound runs the player program and plays a round till a random word is found or no more attempts remain
func (p *LingoGame) PlayRandomRound() (int, error) {
	// initialize round's word
	return p.PlayRound(p.wordList.RandomWord())
}
