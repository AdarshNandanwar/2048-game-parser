#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "board.h"
#include "tile_name.h"
#include "common_header.h"

TileNameNode * tile_name[4][4];
TileNameTrieNode * tile_name_trie_head;

extern int yylineno;

// trie funtions

int trie_insert(char * name){
    TileNameTrieNode * head = tile_name_trie_head;
    int len = strlen(name);
    for(int i = 0; i<len; i++){
        if(head->next[name[i]] == NULL){
            TileNameTrieNode * new_node = (TileNameTrieNode *) malloc(sizeof(TileNameTrieNode));
            new_node->is_word = 0;
            for(int i = 0; i<128; i++){
                new_node->next[i] = NULL;
            }
            head->next[name[i]] = new_node;
        }
        head = head->next[name[i]];
    }
    if(head->is_word) return 0;
    head->is_word = 1;
    return 1;
}

void trie_erase_list(TileNameNode * list_head){
    TileNameNode * head = list_head;
    while(head){
        TileNameTrieNode * trie_head = tile_name_trie_head;
        char * name = head->name;
        int len = strlen(name);
        for(int i = 0; i<len; i++){
            if(trie_head->next[name[i]] == NULL){
                break;
            }
            trie_head = trie_head->next[name[i]];
        }
        if(trie_head){
            trie_head->is_word = 0;
        }
        head = head->next;
    }
}

// list funtions

TileNameNode * insert_name(TileNameNode * head, char * name){
    int status = trie_insert(name);
    if(status == 0){
        throw_error("Variable redeclaration.");
        return head;
    }
    TileNameNode * new_node = (TileNameNode *) malloc(sizeof(TileNameNode));
    new_node->name = strdup(name);
    new_node->next = head;
    return new_node;
}

TileNameNode * merge_name(TileNameNode * head_1, TileNameNode * head_2){
    if(head_1 == NULL) return head_2;
    if(head_2 == NULL) return head_1;
    
    TileNameNode * head = head_1;
    while(head->next){
        head = head->next;
    }
    head->next = head_2;
    return head_1;
}

// tile functions

void name_tile(char * name, int row, int col){
	if(0<=row && row<4 && 0<=col && col<4){
        if(state[row][col] == 0){
            throw_error("Can not name an empty tile.");
            return;
        }
        tile_name[row][col] = insert_name(tile_name[row][col], name);
        printf("2048> Tile <%d,%d> named as \"%s\".\n", row+1, col+1, name);
		print_state();
	    print_state_flat();
	} else {
        throw_error("Invalid co-ordinates. The tile co-ordinates must be in the range {1,2,3,4}.");
	}
}