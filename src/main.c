/**
 * A default main.c file for the MSP432P401R board
 * 
 * Any/all associated files are used in aggreement with their licenses;
 * See the TI and Apache license files for more information.
 */

#include <msp.h>

/* _exit function required to remove compiler errors about references */
void _exit() {
    for (;;) {}
}

int main() {

    /* SPIN FOREVER */
    _exit();
}