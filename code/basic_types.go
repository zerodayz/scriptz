package main

import (
	"fmt"
	"math"
	"math/bits"
	"math/cmplx"
)

var (
	ToBe   bool       = false
	MaxInt int 		  =  (1 << bits.UintSize) / 2 - 1
	MaxInt32 int32	  = math.MaxInt32
	MaxInt64 int64    = math.MaxInt64
	z      complex128 = cmplx.Sqrt(-5 + 12i)
)

func main() {
	fmt.Printf("Type: %T Value: %v\n", ToBe, ToBe)
	fmt.Printf("Type: %T Value: %v\n", MaxInt, MaxInt)
	fmt.Printf("Type: %T Value: %v\n", MaxInt32, MaxInt32)
	fmt.Printf("Type: %T Value: %v\n", MaxInt64, MaxInt64)
	fmt.Printf("Type: %T Value: %v\n", z, z)
}

