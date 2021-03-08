package main

import "fmt"

func main() {
	ch := make(chan int, 100)
	ch <- 3
	ch <- 2
	ch <- 1
	fmt.Println(<-ch)
	fmt.Println(<-ch)
	fmt.Println(<-ch)
}