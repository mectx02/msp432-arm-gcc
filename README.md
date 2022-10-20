# GCC-ARM compiler with the MSP432P401R

If, like me, you want to use the GCC version of the ARM compiler for use with the MSP432P401R board, then 
hopefully this guide will point you in the right direction and avoid all of the pitfalls that I've come across.


## Setup

While theoretically this could be done under environments other than Windows (such as Linux, and I intend to try that 
out soon), right now I can only confirm these steps for Windows with Keil's uVision IDE (any version that supports the 
GCC compiler, which should include the newest one). Therefore, this guide assumes that you are currently working under 
Windows, with the intention of getting this compiler working with Keil uVision.

### Installing the Toolchain
First, download and install the `gcc-arm-none-eabi` tookit from [ARM's website](https://developer.arm.com/downloads/-/gnu-rm). 
The default installation directory is fine (it should default to `C:\Program Files (x86)\GNU ARM Embedded Toolchain\[version]` or 
something similar).

Once installed, Keil must be configured to actually USE the compiler rather than default to it's own installed one. So, 
open the "Manage Project Items" menu, select "Folders/Extensions", and select "Use GCC Compiler (GNU) for ARM Projects". 
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
`
void exit(int) {};
`


#### Assembly file fix
`_exit:       B _exit `


And that's it! Everything should just be able to compile (as long as you configured everything correctly, and you're using the 
correct assembly directives [if coding in assembly]) and run on your MSP board without too much issue.

## What's next?

I don't know. Maybe getting it to work under Linux or something? But I think it should be able to just work without issue - 
the only hard part under anything that's not an IDE is figuring out how to flash finished programs to the board. Still working 
that one out.

