# language
## Commands
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
## Pattern
```
operation direction.

```
## Grammer
```

```
### Testing
```
ASSIGN 7 TO 2,2.
VAR var1 IS 2,2.
VALUE IN 2,3.
ASSIGN VALUE IN 2,2 TO 1,1.
1
```
### ToDo
- fix writing only integers
- code the actual logic
- show verbose errors