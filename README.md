# GCC-ARM compiler with the MSP432 family of boards

If, like me, you want to use the GCC version of the ARM compiler for use with the MSP432 board family, then 
hopefully this guide will point you in the right direction and avoid all of the pitfalls that I've come across.


## Setup with Keil

This part of the guide assumes that you're working under Windows with Keil's uVision IDE. If you're looking for Linux, 
skip down to the next major section.

### Installing the Toolchain
First, download and install the `gcc-arm-none-eabi` tookit from [ARM's website](https://developer.arm.com/downloads/-/gnu-rm). 
The default installation directory is fine (it should default to `C:\Program Files (x86)\GNU ARM Embedded Toolchain\[version]` or 
something similar). I'd recommend adding it to the Windows PATH when its done installing.

Once installed, Keil must be configured to actually USE the compiler rather than default to it's own installed one. So, 
open the "Manage Project Items" menu, select "Folders/Extensions", and enable "Use GCC Compiler (GNU) for ARM Projects". 
Then, point Keil to the recently installed directory folder where the recently installed toolchain is.

### Fiddly Shenanigans
At this point, Keil will now attempt to use the GCC compiler rather than its own. But there's still some setup to do, since 
GCC doesn't know what the heck to do with the files that are being compiled. So, open up "Target Options", select the 
"Linker" tab, and click the three little dots button on the line labeled "Linker Script File". Then, in the Explorer window 
that just opened up, navigate to the following directory (subbing out the part in brackets with values that are most 
applicable to you): `C:\Users\[username]\AppData\Local\Arm\Packs\TexasInstruments\MSP432P4xx_DFP\[version]\Device\Source\msp432p401r.ld`

(Sidenote: that last part will vary depending on where you wanted Keil to install packs to, which is defined during its setup 
program. If you selected the default options when installing, then you should be able to find them in the directory we just pointed.
Otherwise, you'll have to hunt for the specific pack installation directory. Once you find it, the linker script should be in the 
same relative directory: `[packs]\TexasInstruments/MSP432P4xx_DFP\[version]\Device\Source\msp432p401r.ld`.)

Under that same tab, make sure that the option for "Do not use Standard System Starup Files" is unchecked. (Reason is explained below.)

Unfortunately, there's one last step that you will need to complete, and that's to modify the `main` file in your project from 
now until the heat death of the universe. As far as I know, if you use the GCC libraries, the GCC linker is going to throw an error 
along the lines of `undefined reference to _exit` whenever you go and compile (or `undefined reference to _init` if you didn't make 
sure that the Standard System Startup Files option was unchecked, in which case, go and fix that right quick!). I suspect that it has 
something to do with the inbuilt library files of GCC not having that defined or something? Not quite sure, but it's annoying. At least 
the fix is easy: add the following code snippet to at least one of your files (preferably at the end):

#### C file fix
`void _exit() {};`


#### Assembly file fix
`_exit:       B _exit `


And that's it! Everything should just be able to compile (as long as you configured everything correctly, and you're using the 
correct assembly directives [if coding in assembly]) and run on your MSP board without too much issue.



## Setup the GCC Compiler on Linux 

Keil is likely a great piece of software for many since it doesn't require too much extra fiddly business to get it working. But if, 
like me, you ***REALLY*** want to use something like vim when you code, then you might be interested in setting up something like this.

### Installing pre-requisites

Just like above, the GCC toolchain must be installed. If you're working under Linux (if you're on Windows, the best I can offer you is 
Windows' WSL environment), then the best course of action would be to install the `arm-none-eabi-gcc` environment from your package manager.
Typically this means installing `binutils`, `gcc`, and `newlib` packages from `arm-none-eabi`. (Package names vary by distribution, but 
generally you will need these three packages.)


In addition to installing the compiler, having a method for flashing the resulting programs to the board would be insanely helpful. TI 
provides their own GUI interface called [Uniflash](https://www.ti.com/tool/UNIFLASH) which makes it really easy. The only requirement 
for flashing to the board is that the files must be in either a `.bin` or a `.hex` format. (The makefile takes care of that for you.) If you're looking 
for a command-line tool, [MSP430Flasher](https://www.ti.com/tool/MSP430-FLASHER) exists, but I wasn't able to get that to work too well.


### Okay... now what?

Write code! You can either pick an assembly-based project or a C-based project by just opening up one of the files and typing into it. 
C is a lot easier to program, but assembly helps provide a good understanding of what's going on under the hood.

When you're ready to compile your project, call `make [asm, c]` and a `.elf` file should be produced. Then, create the desired output file 
by calling `make [binary, ihex]`. 

Want to reset building your project? `make clean` should clean out all output files as well as the build directory.

If you ever forget the build commands, or you're just confused as to how to compile, just call `make help`.



## Is there anything else that might get added?

No. There might be some example code added, but that would be outside the original scope of this project, which was to provide the necessary 
utilities in order to compile code for the MSP432 boards under Linux. Considering that I managed to add the ability to compile C code (which 
I wasn't even initially considering), I'm calling this project finished for the most part. At this point, it's in a long-term maintenance mode.

However, if you feel that there's an improvement that you can make to this, feel free to add a pull request.

I hope this helps you in your projects.