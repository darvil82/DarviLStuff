#include <stdio.h>
#include <stdlib.h>

typedef struct list_node list_node;
struct list_node {
	list_node* next;
	void* value;
};

typedef struct linked_list linked_list;
struct linked_list {
	list_node* first;
};

linked_list* create_linked_list() {
	linked_list* list = malloc(sizeof(linked_list));
	list->first = NULL;
	return list;
}

void _free_node(list_node* ln) {
	if (!ln)
		return;
	free(ln);
}

list_node* _create_node(void* value) {
	list_node* new_node = malloc(sizeof(list_node));
	new_node->value = value;
	new_node->next = NULL;
	return new_node;
}

list_node* _get_node_by_index(linked_list* ll, size_t index) {
	size_t current_index = 0;
	if (index >= get_size(ll)) {
		return NULL;
	}

	for (list_node* node = ll->first; node, current_index <= index; node = node->next, current_index++) {
		if (current_index == index) {
			return node;
		}
	}
}

void _destroy_node_and_children(list_node* ln) {
	if (ln->next)
		_destroy_node_and_children(ln->next);
	_free_node(ln);
}

void destroy_linked_list(linked_list* ll) {
	if (!ll->first)
		return;
	_destroy_node_and_children(ll->first);
}

void append(linked_list* ll, void* value) {
	list_node* new_node = _create_node(value);

	if (!ll->first) {
		ll->first = new_node;
		return;
	}

	for (list_node* node = ll->first; node; node = node->next) {
		if (!node->next) {
			node->next = new_node;
			return;
		}
	}
}

size_t get_size(linked_list* ll) {
	size_t size = 0;

	for (list_node* node = ll->first; node; node = node->next) {
		size++;
	}

	return size;
}

void remove_last(linked_list* ll) {
	if (!ll->first)
		return;

	for (list_node* node = ll->first; node; node = node->next) {
		if (!node->next->next) {
			_free_node(node->next);
			node->next = NULL;
			return;
		}
	}
}

void* get(linked_list* ll, size_t index) {
	size_t current_index = 0;
	for (list_node* node = ll->first; node, current_index <= index; node = node->next, current_index++) {
		if (current_index == index) {
			return node->value;
		}
	}
}

void print_node(list_node* ln) { printf("%i", *(int*)ln->value); }


void print_linked_list(linked_list* ll) {
	if (!ll->first)
		return;

	printf("[");
	for (list_node* node = ll->first; node; node = node->next) {
		print_node(node);
		if (node->next) {
			printf(", ");
		}
	}
	printf("]\n");
}


int main() {
	int v1 = 12, v2 = 56, v3 = 89, v4 = 942;

	linked_list* ll = create_linked_list();
	append(ll, &v1);
	append(ll, &v2);
	append(ll, &v3);
	append(ll, &v4);

	remove_last(ll);

	print_linked_list(ll);

	printf("size of linked list: %lu\n", get_size(ll));

	printf("second value: %i\n", *(int*)get(ll, 1));

	destroy_linked_list(ll);
}