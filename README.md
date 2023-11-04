# Modified 2048 Game Programming Language
This is a game programming language for a modified 2048 game. The project consists of the following major components:
1. Scanner (`lexer.l`) - Combines characters from the input stream into recognizable units called tokens (lexemes) and removes anything that doesn't contribute to the program's meaning.
1. Parser Translator (`parser.y`) - This consists of a complete syntax-directed translation scheme using bison, a suitable grammar to represent the operations, as well as advanced error handling into the scheme (from semantic all the way down to lexical errors). 
1. Main program (`tile_name.c`, `board.c`) - The driver handles the board state and maintains all the essential data structures, like Trie, required to run the game.

## The Game
This is a game from the 2048-game "family" with the following modifications to the original 2048 game: The game allows subtraction, multiplication, and division in addition to the plain doubling operation at tile mergers. Thus, each move, when it is making two same-value tiles merge, may obliterate them together (making them 0 by subtraction), or reduce them to 1 by divition, or square them by multiplication. In this variation, the goal is also flexible, any number, not necessarily a power of 2, will be achievable.

### Semantics
The game starts as an interactive shell. The beginning prompt is the start state, in which a random 2 or 4 tile is there, others are blank. The state is rendered as a matrix. Subsequently, each line of input from the user is interpreted into an action on the current state, and a new state is produced and rendered as a response. Internally, we track the variable name assignments to tiles and the current state using data structures.

## Commands
- The following commands are allowed:
    ```
    ADD LEFT.
    ADD RIGHT.
    ADD UP.
    ADD DOWN.
    SUBTRACT LEFT.
    SUBTRACT RIGHT.
    SUBTRACT UP.
    SUBTRACT DOWN.
    MULTIPLY LEFT.
    MULTIPLY RIGHT.
    MULTIPLY UP.
    MULTIPLY DOWN.
    DIVIDE LEFT.
    DIVIDE RIGHT.
    DIVIDE UP.
    DIVIDE DOWN.

    ASSIGN <value> TO <x>,<y>.
    VAR <varname> IS <x>,<y>.
    VALUE IN <x>,<y>.
    ```
- `VALUE` command may also be used inside `ASSIGN` command.
    ```
    ASSIGN VALUE IN <x>,<y> TO <x>,<y>.
    ```
- All commands are case-sensitive.
- All commands must end with a full stop '`.`'.
- If the input is taken from a file, ensure it ends with a newline character `'\n'`.

## Sample
Refer to files `input.txt`, `input_sample.txt` and `output.txt`

## Dependencies
You will need the following to run the program:
- gcc
- flex
- bison

### Installation (Linux)
```
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install gcc -y
sudo apt-get install flex -y
sudo apt-get install bison -y
```
## Usage
You can easily run the game programming language using the provided `makefile`.
```
make clean
make
make run
```
Note - To exit the game, use `Ctrl+C`.

<hr>

## Made by - Adarsh Nandanwar