#!/bin/bash

# Setup
nix build
nopswd=./result/bin/nopswd
echo "temppassword" > temppassword.txt
echo "tempdata" > tempdata.txt
correctPassword1="LCqyVhmhlfpJAApb"
correctPassword2="!!Gaj30D^61qP^Rc"

# Cleanup
trap 'rm -f temppassword.txt tempdata.txt' EXIT

# Tests

# 1. Test basic usage
if output=$($nopswd --password-file temppassword.txt testsite testuser); then
  password1=$(echo "$output" | tail -n 1)  # Get the last line (password)
  if [ "$password1" = "$correctPassword1" ]; then
    echo "Test 1 Success"
  else
    echo "Test 1 failed, password consistency broken, expected $correctPassword1 and got $password1"
  fi
else
  echo "Test 1 Failed with exit code $?"
fi

# 2. Test redirects work
if output=$(cat tempdata.txt | $nopswd --password-file temppassword.txt testsite testuser); then
  password2=$(echo "$output" | tail -n 1) 
  if [ "$password1" = "$password2" ]; then
    echo "Test 2 Failed, redirecting is not working"
  else
    if [ "$password2" = "$correctPassword2" ]; then
      echo "Test 2 Success"
    else
      echo "Test 2 failed, password consistency broken, expected $correctPassword2 and got $password2"
    fi
  fi
else
  echo "Test 2 Failed with exit code $?"
fi


