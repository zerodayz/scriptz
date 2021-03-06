package main

import (
	"fmt"
	"math"
)

type Person struct {
	Name string
}

type Circle struct {
	x, y, r float64
}

func circleArea(ci *Circle) float64 {
	return math.Pi * ci.r * ci.r
}

var ci Circle

func (p *Person) Talk() {
	fmt.Println("Hi, my name is", p.Name)
}

func main() {
	// ci := new(Circle)
	// ci = Circle{x: 1, y: 2, r: 3}
	// ci = Circle{3, 2, 1}

	fmt.Printf("%v, %v, %v\n", ci.x, ci.y, ci.r)
	ci.x = 10
	fmt.Printf("%v\n", ci.x)
	fmt.Printf("%v\n", circleArea(&ci))

	//a := new(Person)
	//a.Name = "James"
	//a.Talk()
}
