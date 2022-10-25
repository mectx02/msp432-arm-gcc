# A makefile for compiling (C?)/ASM projects for TI's MSP boards
# Tested with an MSP432P401R board and the GCC for ARM tookit v12
#
# Developed by Mitchell Case (c) 2022



###########
# Options #
###########
# (Ordered from likely to change to 'probably shouldn't touch these')

# Sets the board to compile for (check include/msp.h for possible options)
BOARD = MSP432P401M
BOARD_LOWER = $(shell echo $(BOARD) | sed 's/./\L&/g')


# Sets the name of the output file without regard to the extension
# No quotes are required for this variable; make takes it verbatim
OUTPUT_NAME = output


# Sets the extension of the resulting output file 
# (Options are ihex, binary; sorry, you only get two to flash to the board)
OUTPUT_FILE_TYPE = binary 

ifeq ($(OUTPUT_FILE_TYPE), ihex)
	OUTPUT_EXTENSION = hex
else
	OUTPUT_EXTENSION = bin
endif


# Sets the include directories
# We use a fancy command here to automatically get the compiler's version
# rather than ask the user to do it themselves
GCC_VER = $(shell arm-none-eabi-gcc --version | grep ^arm-none-eabi-gcc | sed 's/^.* //g')


# This sets the directories of the include directories
# These can be changed, but the compiler should be able to find the files in 
# these directories if you move them
TI_INCLUDE  = "./include/TI/include"
TI_SOURCE 	= ./include/TI/source
CMSIS_DIR   = "./include/CMSIS"
GCC_INCLUDE = "/usr/lib/gcc/arm-none-eabi/$(GCC_VER)/include" 					# <--- This one's part of the host system
INCLUDE_STRING = -I$(TI_INCLUDE) -I$(CMSIS_DIR) -I$(GCC_INCLUDE)

# Sets some default options for compiling everything together
COMPILE_FLAGS = -mcpu=cortex-m4 -mthumb -gdwarf-2 -mthumb-interwork -MD $(INCLUDE_STRING)
LINK_FLAGS = -mcpu=cortex-m4 -mthumb -mthumb-interwork -nodefaultlibs -lm



#####################################
# Commands (Edit at your own peril) #
#####################################

# The final stage - linking everything together
main: build/main.o build/startup_$(BOARD_LOWER)_gcc.o build/system_$(BOARD_LOWER).o
	arm-none-eabi-gcc -T "$(TI_SOURCE)/$(BOARD_LOWER).ld" $(LINK_FLAGS) -o $(OUTPUT_NAME).elf build/*.o


# The next three build each required file individually: main, startup, and system
build/main.o: src/main.s
	arm-none-eabi-as $(COMPILE_FLAGS) -o build/main.o src/main.s


build/startup_$(BOARD_LOWER)_gcc.o: $(TI_SOURCE)/startup_$(BOARD_LOWER)_gcc.S
	arm-none-eabi-gcc -c -mapcs-frame $(COMPILE_FLAGS) -D__$(BOARD)__ -o build/startup_$(BOARD_LOWER)_gcc.o $(TI_SOURCE)/startup_$(BOARD_LOWER)_gcc.S


build/system_$(BOARD_LOWER).o: $(TI_SOURCE)/system_$(BOARD_LOWER).c
	arm-none-eabi-gcc -c -mapcs-frame $(COMPILE_FLAGS) -D__$(BOARD)__ -o build/system_$(BOARD_LOWER).o $(TI_SOURCE)/system_$(BOARD_LOWER).c


# In case you want to re-build your project for some odd reason and start from 
# scratch, but I won't judge you for that
clean:
	rm -rfv build/*.{d,o}
	rm -rfv *.elf
	rm -rfv *.bin
	rm -rfv *.hex


# Getting ready to flash the resulting output file
convert:
	arm-none-eabi-objcopy -O ihex $(OUTPUT_NAME).elf $(OUTPUT_NAME).$(OUTPUT_EXTENSION)