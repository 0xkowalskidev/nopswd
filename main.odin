package main

import "core:crypto/hash"
import "core:fmt"
import "core:os"
import "core:strings"

// Base character set for the password
PASSWORD_CHARS :: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*+-=?"
PASSWORD_LENGTH :: 16

main :: proc() {
	args := os.args[1:]
	if len(args) < 2 {
		fmt.println("Usage: nopswd <site/app> <username/email> [master password...]")
		fmt.println("Example: nopswd example.com user@example.com mysecret")
		fmt.println("Pipe example: nopswd example.com user@example.com mysecret < secret.txt")
		os.exit(1)
	}

	site := strings.to_lower(args[0])
	username := strings.to_lower(args[1])
	master_password := strings.join(args[2:], " ")

	// Append piped input if present
	if stdin_data, ok := os.read_entire_file(os.stdin); ok && len(stdin_data) > 0 {
		master_password = strings.concatenate({master_password, " ", string(stdin_data)})
	}

	input := strings.concatenate({site, username, master_password})
	hash_bytes := hash.hash(hash.Algorithm.SHA256, input)
	chars := PASSWORD_CHARS
	password := make([]u8, PASSWORD_LENGTH)
	for i in 0 ..< PASSWORD_LENGTH {
		index := int(hash_bytes[i % len(hash_bytes)]) % len(chars)
		password[i] = chars[index]
	}

	fmt.printf("Generated password for %s (%s):\n%s\n", site, username, password)
}
