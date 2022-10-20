# GCC-ARM compiler with the MSP432P401R

If, like me, you want to use the GCC version of the ARM compiler for use with the MSP432P401R board, then 
hopefully this guide will point you in the right direction and avoid all of the pitfalls that I've come across.


## Setup

While theoretically this could be done under environments other than Windows (such as Linux, and I intend to try that 
out soon), right now I can only confirm these steps for Windows with Keil's uVision IDE (any version that supports the 
GCC compiler, which should include the newest one).

First, download and install the `gcc-arm-none-eabi` tookit from [ARM's website](https://developer.arm.com/downloads/-/gnu-rm). 
