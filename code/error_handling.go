package main

import "fmt"

func main() {
	fmt.Printf("%T\n", TestFunc())
}

func TestFunc() error {
	return IgnorableError("recognized csr %q as %v but subject access review was not approved", "csr.Name", 10)
}


// IgnorableError returns an error that we shouldn't handle (i.e. log) because
// it's spammy and usually user error. Instead we will log these errors at a
// higher log level. We still need to throw these errors to signal that the
// sync should be retried.
func IgnorableError(s string, args ...interface{}) error {
	return ignorableError(fmt.Sprintf(s, args...))
}

type ignorableError string

func (e ignorableError) Error() string {
	return string(e)
}
