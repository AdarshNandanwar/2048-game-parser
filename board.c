#include <stdio.h>
#include <stdlib.h>
#include "board.h"
#include "tile_name.h"

extern int yylineno;
int state[4][4];

void initialize_state(){
	for(int i = 0; i<4; i++){
		for(int j = 0; j<4; j++){
			state[i][j] = 0;
			tile_name[i][j] = NULL;
		}
	}
	tile_name_trie_head = (TileNameTrieNode *) malloc(sizeof(TileNameTrieNode));
	tile_name_trie_head->is_word = 0;
	for(int i = 0; i<128; i++){
		tile_name_trie_head->next[i] = NULL;
	}
	insert_random_tile();
}

void insert_random_tile(){
	int free_tiles = 0;
	for(int i = 0; i<4; i++){
		for(int j = 0; j<4; j++){
			if(state[i][j] == 0){
				free_tiles++;
			}
		}
	}
	if(free_tiles == 0){
		// game over
		return;
	}
	int pos = rand()%free_tiles;
	int val = rand()%2;
	int offset = -1;
	for(int i = 0; i<4; i++){
		for(int j = 0; j<4; j++){
			if(state[i][j] == 0){
				offset++;
			}
			if(offset == pos){
				state[i][j] = (val?2:4);
				return;
			}
		}
	}
}

void transpose(){
	for(int i = 0; i<4; i++){
		for(int j = 0; j<i; j++){
			int temp = state[i][j];
			state[i][j] = state[j][i];
			state[j][i] = temp;
			TileNameNode * temp_node = tile_name[i][j];
			tile_name[i][j] = tile_name[j][i];
			tile_name[j][i] = temp_node;
		}
	}
}

void mirror(){
	for(int i = 0; i<4; i++){
		for(int j = 0; j<4/2; j++){
			int temp = state[i][j];
			state[i][j] = state[i][4-1-j];
			state[i][4-1-j] = temp;
			TileNameNode * temp_node = tile_name[i][j];
			tile_name[i][j] = tile_name[i][4-1-j];
			tile_name[i][4-1-j] = temp_node;
		}
	}
}

void shift_left(){
    for(int i = 0; i<4; i++){
        int left = 0;
        for(int j = 0; j<4; j++){
            if(state[i][j] > 0){
				state[i][left] = state[i][j];
				tile_name[i][left] = tile_name[i][j];
				left++;
			} 
        }
        for(;left<4; left++){
            state[i][left] = 0;
			tile_name[i][left] = NULL;
        }
    }
}

void operate_left(char oper){
    for(int i = 0; i<4; i++){
        int left = -1;
        int left_value = 0;
        for(int j = 0; j<4; j++){
            if(state[i][j] > 0){
                if(left >= 0 && left_value > 0 && state[i][j] == left_value){
                    switch(oper){
                        case 'A': state[i][left] += state[i][j]; break;
                        case 'S': state[i][left] -= state[i][j]; break;
                        case 'M': state[i][left] *= state[i][j]; break;
                        case 'D': state[i][left] /= state[i][j]; break;
                    }
					merge_name(tile_name[i][left], tile_name[i][j]);
					trie_erase_list(tile_name[i][j]);
					tile_name[i][j] = NULL;
					state[i][j] = 0; 
                }
                left = j;
                left_value = state[i][j];
            } 
        }
    }
}

void make_move(char oper, char dir){
	switch(dir){
		case 'L': {
			shift_left();
			operate_left(oper);
			shift_left();
			break;
		}
		case 'R': {
			mirror();
			shift_left();
			operate_left(oper);
			shift_left();
			mirror();
			break;
		}
		case 'U': {
			transpose();
			shift_left();
			operate_left(oper);
			shift_left();
			transpose();
			break;
		}
		case 'D': {
			transpose();
			mirror();
			shift_left();
			operate_left(oper);
			shift_left();
			mirror();
			transpose();
			break;
		}
	}
	insert_random_tile();
	printf("2048> Moved ");
	switch(dir){
		case 'L': printf("left"); break;
		case 'R': printf("right"); break;
		case 'U': printf("up"); break;
		case 'D': printf("down"); break;
	}
	printf(" using ");
	switch(oper){
		case 'A': printf("addition"); break;
		case 'S': printf("subtraction"); break;
		case 'M': printf("multiplication"); break;
		case 'D': printf("division"); break;
	}
	printf(". Random tile added.\n");
	print_state();
	print_state_flat();
}

int get_value(int row, int col){
	// remove this function. This is for testing only. this is supposed to be a non-terminal
	if(0<=row && row<4 && 0<=col && col<4){
		return state[row][col];
	} else {
		printf("[line %d] error: Tile co-ordinates out of bounds. The tile co-ordinates must be in the range {1,2,3,4}.\n", yylineno);
		fprintf(stderr, "-1\n");
		return -1;
	}
}

void assign_value(int val, int row, int col){
	if(val == -1){
		// error occured in QUERY production
		return;
	}
	// printf("assigning value %d to <%d, %d>\n", val, row+1, col+1); 
	if(0<=row && row<4 && 0<=col && col<4){
		state[row][col] = val;
		printf("2048> Assigned the value %d to <%d,%d>.\n", val, row+1, col+1);
		print_state();
		print_state_flat();
	} else {
		printf("[line %d] error: Tile co-ordinates out of bounds. The tile co-ordinates must be in the range {1,2,3,4}.\n", yylineno);
		fprintf(stderr, "-1\n");
	}
}

void print_state(){
	printf("2048> The current state is:\n---------------------------------\n");
	for(int i = 0; i<4; i++){
		for(int j = 0; j<4; j++){
			if(state[i][j] == 0){
				printf("|\t");
			} else {
				printf("|%d\t", state[i][j]);
			}
		}
		printf("|\n---------------------------------\n");
	}
}

void print_state_flat(){
	// print tile values
	for(int i = 0; i<4; i++){
		for(int j = 0; j<4; j++){
			fprintf(stderr, "%d ", state[i][j]);
		}
	}
	// print variable names
	for(int i = 0; i<4; i++){
		for(int j = 0; j<4; j++){
			TileNameNode * head = tile_name[i][j];
			while(head){
				fprintf(stderr, "%d,%d%s ", i+1, j+1, head->name);
				head = head->next;
			}
		}
	}
	fprintf(stderr, "\n");
}