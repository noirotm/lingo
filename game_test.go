package main

import "testing"

type CheckEntry struct {
	word         string
	guess        string
	expectedMask string
}

var checks = []CheckEntry{
	{"flower", "flower", "OOOOOO"},
	{"flower", "rewolf", "??????"},
	{"stories", "element", "?XXXXX?"},
	{"cozies", "tosses", "XOXXOO"},
}

func TestWordChecking(t *testing.T) {
	for _, entry := range checks {
		if res := checkWord(entry.word, entry.guess); res != entry.expectedMask {
			t.Error(res, "!=", entry.expectedMask)
		}
	}

}
