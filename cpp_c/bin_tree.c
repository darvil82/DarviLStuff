#include <stdlib.h>
#include <stdio.h>
#include <time.h>

typedef struct Node Node;
struct Node {
	int value;
	Node* left;
	Node* right;
};



Node* create_node(int value) {
	Node* newNode = (Node*)malloc(sizeof(Node));
	newNode->left = NULL;
	newNode->right = NULL;
	newNode->value = value;
	return newNode;
}

void insert_node(Node* node, int value) {
	if (value > node->value) {
		if (!node->right) {
			node->right = create_node(value);
			return;
		}
		insert_node(node->right, value);
	} else {
		if (!node->left) {
			node->left = create_node(value);
			return;
		}
		insert_node(node->left, value);
	}
}

void _print_tree_r(Node* node, uint depth) {
	if (!node) return;

	_print_tree_r(node->right, depth + 1);
	printf("%*s -> %d\n", depth*5, "", node->value);
	_print_tree_r(node->left, depth + 1);
}

void print_tree(Node* node) {
	_print_tree_r(node, 0);
}



int main(int argc, char const *argv[]) {
	srand(time(NULL));

	Node* n = create_node(500);

	for (int x = 0; x < 35; x++) {
		insert_node(n, rand() % 1001);
	}

	print_tree(n);
}