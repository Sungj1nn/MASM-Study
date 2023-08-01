#include <stdio.h>

extern "C" {
	void printFunc(void);
};

int main(void) {
	printf("Calling printFunc...\n");
	printFunc();
	printf("Returned from printFunc\n");
}