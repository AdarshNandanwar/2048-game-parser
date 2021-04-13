#ifndef BOARD_HEADER
#define BOARD_HEADER

extern int DEBUG;
extern int state[4][4];

extern void initialize_state();
extern void insert_random_tile();
extern void make_move(char oper, char dir);
extern int get_value(int row, int col);
extern void assign_value(int val, int row, int col);
extern void print_state();
extern void print_state_flat();

#endif
