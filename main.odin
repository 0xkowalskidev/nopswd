package main

import "core:crypto/hash"
import "core:fmt"
import "core:os"
import "core:strings"

// Base character set for the password
PASSWORD_CHARS :: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*+-=?"

normalize_site :: proc(site: string) -> string {
	lower := strings.to_lower(site)
	return strings.has_prefix(lower, "www.") ? lower[4:] : lower
}

generate_password :: proc(master_password, site, username: string, length: int) -> string {
	normalized_site := normalize_site(site)
	input := strings.concatenate({master_password, normalized_site, username})
	hash_bytes := hash.hash(hash.Algorithm.SHA256, input)
	chars := PASSWORD_CHARS
	password := make([]u8, length)
	for i in 0 ..< length {
		index := int(hash_bytes[i % len(hash_bytes)]) % len(chars)
		password[i] = chars[index]
	}
	return string(password[:])
}

main :: proc() {
	args := os.args[1:]
	if len(args) < 2 {
		fmt.println("Usage: nopswd <site> <username> [master_password_parts...]")
		fmt.println("Example: nopswd example.com user@example.com mysecret")
		fmt.println("Pipe example: nopswd example.com user@example.com mysecret < input.txt")
		os.exit(1)
	}

	site := args[0]
	username := args[1]
	master_parts := args[2:]
	master_password := strings.join(master_parts, " ")

	// Append piped input if present
	if stdin_data, ok := os.read_entire_file(os.stdin); ok && len(stdin_data) > 0 {
		master_password = strings.concatenate({master_password, " ", string(stdin_data)})
	}

	password_length := 16
	password := generate_password(master_password, site, username, password_length)
	fmt.printf("Generated password for %s (%s): %s\n", site, username, password)
}
