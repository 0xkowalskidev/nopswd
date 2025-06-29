package main

import "core:crypto/hash"
import "core:fmt"
import "core:os"
import "core:strings"

foreign import libc "system:c"

termios :: struct {
	_: [12]u8,  // padding for iflag, oflag, cflag
	c_lflag: u32,
	_: [20]u8,  // padding for c_cc
}

TCSANOW, TCSAFLUSH :: 0, 2
ECHO, ICANON :: 0x00000008, 0x00000002

foreign libc {
	tcgetattr :: proc(fd: i32, termios_p: ^termios) -> i32 ---
	tcsetattr :: proc(fd: i32, optional_actions: i32, termios_p: ^termios) -> i32 ---
}

main :: proc() {
	args := os.args[1:]
	if len(args) < 2 {
		fmt.println("Usage: nopswd <site/app> <username/email> [additional data...] [< piped_data]")
		os.exit(1)
	}

	// Normalize inputs to lowercase for consistency
	site, username := strings.to_lower(args[0]), strings.to_lower(args[1])
	additional_data := strings.join(args[2:], " ")

	// Include any piped data in the hash
	if stdin_data, ok := os.read_entire_file(os.stdin); ok && len(stdin_data) > 0 {
		additional_data = strings.concatenate({additional_data, " ", string(stdin_data)})
	}

	// Prompt for hidden master password
	fmt.print("Master password: ")
	os.flush(os.stdout)
	
	// Disable terminal echo for secure password input
	original_termios: termios
	tcgetattr(0, &original_termios)
	defer tcsetattr(0, TCSANOW, &original_termios) // Always restore on exit
	new_termios := original_termios
	new_termios.c_lflag &= ~u32(ECHO | ICANON)
	tcsetattr(0, TCSAFLUSH, &new_termios)
	
	// Read password one character at a time
	password_buffer: [256]u8
	password_len := 0
	for {
		buffer: [1]u8
		if _, err := os.read(os.stdin, buffer[:]); err != nil do break
		if buffer[0] == '\n' || buffer[0] == '\r' do break
		if buffer[0] == 127 || buffer[0] == 8 { // Handle backspace
			if password_len > 0 do password_len -= 1
		} else if password_len < len(password_buffer) - 1 {
			password_buffer[password_len] = buffer[0]
			password_len += 1
		}
	}
	
	fmt.println()
	
	// Generate deterministic password from all inputs
	hash_bytes := hash.hash(hash.Algorithm.SHA256, strings.concatenate({site, username, string(password_buffer[:password_len]), additional_data}))
	for i in 0 ..< len(password_buffer) do password_buffer[i] = 0 // Clear sensitive data
	chars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*+-=" // Char set, password will only use these chars
  password_length := 16
  password := make([]u8, password_length)
	for i in 0 ..< password_length{
		password[i] = chars[int(hash_bytes[i % len(hash_bytes)]) % len(chars)]
	}

	fmt.printf("Generated password for %s (%s):\n%s\n", site, username, password)
}
