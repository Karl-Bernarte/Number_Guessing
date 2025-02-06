#!/bin/bash

# This is a test change
# Testing again
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
echo "Enter your username: "
read USERNAME

# Check if the user exists
RETURNING_USER=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")

if [[ -z $RETURNING_USER ]]
then
  # New user
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
  INSERTED_USER=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")
else
  # Returning user
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")

  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\n"
fi

# Grab user_id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

# Initialize variables
TRIES=1
GUESS=0

# Guessing function
GUESSING_MACHINE() {
  read GUESS

  # Validate input and check against the secret number
  while [[ $GUESS =~ ^[0-9]+$ && $GUESS -ne $SECRET_NUMBER ]]
  do
    TRIES=$((TRIES + 1))
    
    if [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    elif [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    fi
    read GUESS
  done

  # If input is invalid
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    GUESSING_MACHINE
  fi
}

# Start the game
echo "Guess the secret number between 1 and 1000:"
GUESSING_MACHINE

# When the guess is correct, print the success message and insert the game result
echo -e "\nYou guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
INSERTED_GAME=$($PSQL "INSERT INTO games (user_id, guesses) VALUES ($USER_ID, $TRIES)")

# Script ends here
