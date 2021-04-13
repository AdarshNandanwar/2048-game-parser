#ifndef TILE_NAME_HEADER
#define TILE_NAME_HEADER


// linked list node
typedef struct TileNameNode {
    char * name;
    struct TileNameNode * next;
} TileNameNode;

extern TileNameNode * tile_name[4][4];

TileNameNode * insert_name(TileNameNode * head, char * name);
TileNameNode * merge_name(TileNameNode * head_1, TileNameNode * head_2);


// trie node
typedef struct TileNameTrieNode {
    int is_word;
    struct TileNameTrieNode * next[128];
} TileNameTrieNode;

extern TileNameTrieNode * tile_name_trie_head;

int trie_insert(char * name);
void trie_erase_list(TileNameNode * list_head);



extern void name_tile(char * name, int row, int col);

#endif