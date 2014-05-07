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
	{"flower", "floflo", "OOOXXX"},
	{"flower", "florqe", "OOO?X?"},
	{"flower", "kittis", "XXXXXX"},
	{"elephant", "eeeeeeee", "OXOXXXXX"},
	{"elephant", "zezeeeee", "X?X?XXXX"},
	{"elephant", "zrzeeeee", "XXX??XXX"},
	{"stories", "element", "?XXXXX?"},
	{"cozies", "tosses", "XOXXOO"},
}

func TestCheckWord(t *testing.T) {
	for _, entry := range checks {
		if res := checkWord(entry.word, entry.guess); res != entry.expectedMask {
			t.Error(res, "!=", entry.expectedMask)
		}
	}
}
