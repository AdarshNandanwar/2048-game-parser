# 2048-game-parser
The project consists of parser-translator (that means a complete syntax-directed translation scheme) for a modified 2048 game programming language.

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
## Usage
```
make clean
make
make run
```
- Note - If the input is taken from a file, ensure it ends with a newline character `'\n'`.
## Dependencies
- gcc
- flex
- bison

<hr>

#### Made by
- Name: Adarsh Nandanwar
- BITS ID: 2018A7PS0396G