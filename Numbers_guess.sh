#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

DISPLAY(){

echo -e "\n\n~~ Number Guessing Game ~~\n\n"

echo -e "\nEnter your username:"
read USERNAME

NAME=$($PSQL "SELECT username FROM players WHERE username='$USERNAME' ")
PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME' ")

if [[ -z $NAME ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here. "
  INSER_NAME=$($PSQL "INSERT INTO players(username) VALUES('$USERNAME')")
  PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME' ")
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(player_id) FROM games WHERE player_id='$PLAYER_ID'")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guess) FROM games WHERE player_id='$PLAYER_ID'")
  echo -e "\nWelcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

GAME
}


GAME(){
SECRET_NUMBER=$((RANDOM % 1000 + 1))
TRIES=0
GUESSED=0

echo -e "\nGuess the secret number between 1 and 1000:"
while [[ $GUESSED = 0 ]]; do
    read GUESS

    #if not a number
    if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
      echo -e "\nThat is not an integer, guess again:"
    #if correct guess
    elif [[ $SECRET_NUMBER = $GUESS ]]; then
      TRIES=$(($TRIES + 1))
      echo -e "\nYou guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
      #insert into db
      INSERTED_TO_GAMES=$($PSQL "INSERT INTO games(player_id, number_of_guess) values($PLAYER_ID, $TRIES)")
      GUESSED=1
    #if greater
    elif [[ $SECRET_NUMBER -gt $GUESS ]]; then
      TRIES=$(($TRIES + 1))
      echo -e "\nIt's higher than that, guess again:"
    #if smaller
    else
      TRIES=$(($TRIES + 1))
      echo -e "\nIt's lower than that, guess again:"
    fi
  done

}

DISPLAY