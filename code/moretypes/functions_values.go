package main

import (
	"fmt"
	"math"
)

func compute(fn func(float64, float64) float64) float64 {
	return fn(3, 4)
}

func main() {
	hypot := func(x, y float64) float64 {
		fmt.Printf("x: %g, y: %g\n", x, y)
		fmt.Println("x*x + y*y: ", x*x + y*y)
		fmt.Println("math.Sqrt(): ", math.Sqrt(x*x + y*y))
		return math.Sqrt(x*x + y*y)
	}
	fmt.Println(hypot(5, 12))

	fmt.Println(compute(hypot))
	fmt.Println(compute(math.Pow))
	var x, y float64 = 3, 4
	fmt.Printf("%g\n", math.Pow(x, y))
	fmt.Printf("%g\n", y**x)
}
