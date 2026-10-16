#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
 
echo "Enter your username:"
read USERNAME
 
# Buscar usuario
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
 
if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME')" > /dev/null
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
 
# Numero secreto entre 1 y 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESSES=0
 
echo "Guess the secret number between 1 and 1000:"
 
while true
do
  read GUESS
 
  # Validar que sea entero
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi
 
  (( GUESSES++ ))
 
  if (( GUESS > SECRET_NUMBER ))
  then
    echo "It's lower than that, guess again:"
  elif (( GUESS < SECRET_NUMBER ))
  then
    echo "It's higher than that, guess again:"
  else
    break
  fi
done
 
# Guardar la partida
$PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $GUESSES)" > /dev/null
 
echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
