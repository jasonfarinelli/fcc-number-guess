#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_game --tuples-only -c"

NUMBER=$(( RANDOM % 1000 + 1)) 
NUMBER_OF_GUESSES=0

PLAY_GAME() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo "Guess the secret number between 1 and 1000:"
  fi
  read GUESS
  NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))

  #If guess is not a number
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    PLAY_GAME "That is not an integer, guess again:"
  fi

  if [[ $GUESS -eq $NUMBER ]]
  then
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER. Nice job!"
    GAME_OVER
  else
    if [[ $GUESS -lt $NUMBER ]]
    then
      PLAY_GAME "It's higher than that, guess again:"
    else
      if [[ $GUESS -gt $NUMBER ]]
      then
        PLAY_GAME "It's lower than that, guess again:"
      else 
        echo "Logic Error"
      fi
    fi
  fi
}

GAME_OVER() {
  if [[ -z $USER_ID ]]
  then
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  fi

  INSERT_GAME_DATA_RESULT=$($PSQL "INSERT INTO games (user_id, number_of_guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")
}

echo 'Enter your username:'
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

#If user data present, print welcome back info
if [[ ! -z $USER_ID ]]
then
  GAME_DATA=$($PSQL "SELECT COUNT(game_id), MIN(number_of_guesses) FROM games WHERE user_id = $USER_ID")
  echo $GAME_DATA | while read NUMBER_OF_GAMES BAR BEST_SCORE
  do
    echo "Welcome back, $USERNAME! You have played $NUMBER_OF_GAMES games, and your best game took $BEST_SCORE guesses."
  done
#If no user data present, print welcome info
else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
fi

PLAY_GAME
