package main

import "fmt"

func adder() func() int {
	i := 0
	return func() int {
		i += 1
		return i
	}
}

func main() {
	add := adder()
	for i := 0; i < 10; i++ {
		fmt.Println(add())
	}
}
