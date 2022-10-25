/**
 * A default main assembly file for the MSP432P401R board
 * 
 * Any/all associated files are used in aggreement with their licenses;
 * See the TI and Apache license files for more information.
 */

.file "main"
.syntax unified
.cpu cortex-m4
.thumb

.text

.global main
.global _exit


main:
    @ Start your programming work here




/* Default _exit 'function' so that the compiler doesn't complain */
_exit:
    B _exit


/* You may not need this directive, so feel free to just delete it as needed */
.data

.end
