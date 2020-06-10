package main

import "fmt"

func main() {
	var s []int
	printSlice(s)

	// append works on nil slices.
	s = append(s, 0)
	printSlice(s)

	// The slice grows as needed.
	s = append(s, 1)
	printSlice(s)

	s = append(s, 2)
	printSlice(s)

	s = append(s, 3)
	printSlice(s)

	s = append(s, 4)
	printSlice(s)

	s = append(s, 5)
	printSlice(s)

	// We can add more than one element at a time.
	s = append(s, 6, 7, 8)
	printSlice(s)
}

func printSlice(s []int) {
	fmt.Printf("len=%d cap=%d %v\n", len(s), cap(s), s)
}
