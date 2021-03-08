package main

import (
	"golang.org/x/tour/wc"
	"strings"
)

func WordCount(s string) map[string]int {
	r := make(map[string]int)

	ss := strings.Fields(s)
	for i := 0; i < len(ss); i++ {
		key := ss[i]
		r[key] += 1
	}
	return r
}

func main() {
	wc.Test(WordCount)
}

