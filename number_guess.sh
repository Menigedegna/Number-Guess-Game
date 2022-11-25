#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

# Build a number guessing game

NUMBER_TO_GUESS=$(( RANDOM % 999 + 1 ))

echo "Enter your username:"
read PLAYER_USERNAME

#get player id
PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='$PLAYER_USERNAME'")
PLAYER_ID=$(echo $PLAYER_ID | sed -r 's/^ *| *$//g')
#if not found
if [[ -z $PLAYER_ID ]]
then
  #insert player
  INSERT_PLAYER=$($PSQL "INSERT INTO players(username) VALUES('$PLAYER_USERNAME')")
  #get player id
  PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='$PLAYER_USERNAME'")
  PLAYER_ID=$(echo $PLAYER_ID | sed -r 's/^ *| *$//g')
  #get games_played
  GAMES_PLAYED=0
  #get best game
  BEST_GAME=NULL
  #welcome player
  echo "Welcome, $PLAYER_USERNAME! It looks like this is your first time here."
else
  #get username
  PLAYER_USERNAME=$($PSQL "SELECT username FROM players WHERE player_id=$PLAYER_ID")
  PLAYER_USERNAME=$(echo $PLAYER_USERNAME | sed -r 's/^ *| *$//g') 
  #get games_played
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE player_id=$PLAYER_ID")
  GAMES_PLAYED=$(echo $GAMES_PLAYED | sed -r 's/^ *| *$//g')
  #get best_game
  BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE player_id=$PLAYER_ID")
  BEST_GAME=$(echo $BEST_GAME | sed -r 's/^ *| *$//g')
  #welcome player
  echo "Welcome back, $PLAYER_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi


#guess number
ROUND=1
echo "Guess the secret number between 1 and 1000:"
read GUESSED_NUMBER
until [[ $GUESSED_NUMBER == $NUMBER_TO_GUESS ]]
do 
  #if not an integer
  if [[ ! $GUESSED_NUMBER =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  fi
  #if numer is lower
  if [[ $NUMBER_TO_GUESS < $GUESSED_NUMBER ]]
  then 
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  read GUESSED_NUMBER
  ROUND=$(( $ROUND + 1 ))
  if [[ $GUESSED_NUMBER == $NUMBER_TO_GUESS ]]
  then 
    echo "You guessed it in $ROUND tries. The secret number was $NUMBER_TO_GUESS. Nice job!"
  fi
done

#get best game
if [[ -z $BEST_GAME ]]
then
  BEST_GAME=$ROUND
else 
  if [[ $BEST_GAME > $ROUND ]]
  then 
    BEST_GAME=$ROUND
  fi
fi

#get games played
GAMES_PLAYED=$(( $GAMES_PLAYED +1 ))
#update table
INSERT_GAME=$($PSQL "UPDATE players SET games_played=$GAMES_PLAYED WHERE player_id=$PLAYER_ID")
INSERT_GAME=$($PSQL "UPDATE players SET best_game=$BEST_GAME WHERE player_id=$PLAYER_ID")

