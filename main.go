package main

import (
	"bufio"
	"crypto/sha256"
	"flag"
	"fmt"
	"os"
	"strings"

	"golang.org/x/term"
)

const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*+-="

func main() {
	passwordFile := flag.String("password-file", "", "Read master password from file")
	flag.Parse()

	args := flag.Args()
	if len(args) < 2 {
		fmt.Fprintf(os.Stderr, "Usage: %s [--password-file file] <site/app> <username/email> [additional data...] [< redirected_data]\n", os.Args[0])
		os.Exit(1)
	}

	site := args[0]
	username := args[1]
	additionalData := strings.Join(args[2:], " ")

	// Read from stdin if available (redirected data)
	stat, _ := os.Stdin.Stat()
	if (stat.Mode() & os.ModeCharDevice) == 0 {
		scanner := bufio.NewScanner(os.Stdin)
		var stdinData []string
		for scanner.Scan() {
			stdinData = append(stdinData, scanner.Text())
		}
		if len(stdinData) > 0 {
			additionalData += " " + strings.Join(stdinData, " ")
		}
	}

	// Get master password
	var masterPassword []byte
	var err error
	
	if *passwordFile != "" {
		masterPassword, err = os.ReadFile(*passwordFile)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error reading password file: %v\n", err)
			os.Exit(1)
		}
		masterPassword = []byte(strings.TrimSpace(string(masterPassword)))
	} else {
		fmt.Fprint(os.Stderr, "Master password: ")
		tty, err := os.Open("/dev/tty")
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error opening tty: %v\n", err)
			os.Exit(1)
		}
		defer tty.Close()
		
		masterPassword, err = term.ReadPassword(int(tty.Fd()))
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error reading password: %v\n", err)
			os.Exit(1)
		}
		fmt.Fprintln(os.Stderr)
	}

	// Generate password
	input := site + username + string(masterPassword) + additionalData
	hash := sha256.Sum256([]byte(input))

	password := make([]byte, 16)
	for i := 0; i < 16; i++ {
		password[i] = charset[int(hash[i])%len(charset)]
	}

	fmt.Println(string(password))
}