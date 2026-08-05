package main

import (
	"io"
	"os"
)

func main() {
	var input string
	var output string
	for i := 1; i < len(os.Args); i++ {
		arg := os.Args[i]
		if arg == "-o" && i+1 < len(os.Args) {
			output = os.Args[i+1]
			i++
		} else if len(arg) > 0 && arg[0] != '-' {
			input = arg
		}
	}

	if input != "" && output != "" && input != output {
		in, err := os.Open(input)
		if err == nil {
			defer in.Close()
			out, err := os.Create(output)
			if err == nil {
				defer out.Close()
				io.Copy(out, in)
			}
		}
	}
	os.Exit(0)
}
