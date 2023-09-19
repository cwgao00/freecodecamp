#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games")

# Read Input From games.csv 
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WIN_GOALS OPP_GOALS

do
  # Skip the first line
  if [[ $YEAR != 'year' ]]
  then
    # Insert team_id
    INSERT_TEAM_ID=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER'), ('$OPPONENT') ON CONFLICT(name) DO NOTHING")
    # Insert into games
    INSERT_GAMES=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
    VALUES($YEAR, '$ROUND', (SELECT team_id FROM teams WHERE name = '$WINNER'), (SELECT team_id FROM teams WHERE name = '$OPPONENT'), 
    $WIN_GOALS, $OPP_GOALS)")
    # Print out insert
    if [[ $INSERT_GAMES = "INSERT 0 1" ]]
    then
      echo Inserted into games: $YEAR, $ROUND, $WINNER, $OPPONENT, $WIN_GOALS, $OPP_GOALS
    fi
  fi
done