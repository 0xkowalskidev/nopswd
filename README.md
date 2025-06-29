# nopswd

Deterministic stateless password manager - same inputs always generate the same password.

nopswd will generate a 16 character long password from this character set:

```
abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*+-=
```

Some websites/apps may have poor security practices that enforce uniformity in passwords (e.g., 1 special char, 1 uppercase char), it is possible that nopswd will generate a password that does not fit their criteria.
In this case you can simply add a "2" or something in the additional data section. This is meant to be minimal after all.

## Usage

```bash
nopswd <site/app> <username/email> [additional data...] [< redirected_data]
```

## Examples

```bash
nopswd github.com user@example.com 
nopswd netflix user@example.com 2  # When forced to change password 
nopswd github.com user@example.com < extradata.txt # Redirect in extra data
nopswd --password-file mypassword.txt github.com user@example.com < extradata.txt # Redirect in extra data
```

You will be asked for a hidden master password, don't forget it.

## Build

```bash
nix build
```

I use nix, but you can use:

```bash
go build -o nopswd main.go
```

if you don't.

## How it works

Generates passwords using SHA256(site + username + master_password + additional_data).
No storage, no sync, no state. Loses all passwords if you forget master password/site/user, so don't do that.
