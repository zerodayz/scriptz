package main

import "fmt"

func hello(x string) (n string) {
	n = " " + x
	return
}

func main() {
	defer fmt.Println("First Hello")
	defer fmt.Println("Second Hello")
	defer fmt.Println("Last Hello")
	name := "world"
	// var name string = "world"

	fmt.Print("Hello")
	fmt.Println(hello(name))
}
