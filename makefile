# A makefile for compiling C/ASM projects for TI's MSP boards
# Tested with an MSP432P401R board and the GCC for ARM tookit
#
# Developed by Mitchell Case (c) 2023



###########
# Options #
###########

# Sets the board to compile for (check include/TI/include for possible options)
BOARD = MSP432P401R
BOARD_LOWER = $(shell echo $(BOARD) | sed 's/./\L&/g')


# Sets the name of the output file without regard to the extension
# No quotes are required for this variable; make takes it verbatim
OUTPUT_NAME = output


# We use a fancy command here to automatically get the compiler's version
# rather than ask the user to do it themselves (unless you want to do it yourself)
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


help:
	@echo ""
	@echo "COMPILE COMMANDS"
	@echo "--------------------"
	@echo "make asm:	Compiles your assembly project with main.s as the main file"
	@echo "make c:		Compiles your C project with main.c as the main file"
	@echo "make clean: 	Cleans up all files generated from compilation"
	@echo ""
	@echo "DELIVERY COMMANDS"
	@echo "--------------------"
	@echo "make binary: 	Converts the resulting output file to .bin"
	@echo "make ihex:   	Converts the resulting output file to .hex"
	@echo ""
	@echo ""
	@echo "You can make any necessary changes to board selection, file compilation, "
	@echo "and include directories in the makefile."
	@echo ""


# This command builds an assembly-based project together
asm: src/main.s
	arm-none-eabi-as $(COMPILE_FLAGS) -o build/main.o src/main.s
	make link

# This command builds a C-based project. Mostly the same.
c: src/main.c
	arm-none-eabi-gcc -c $(COMPILE_FLAGS) -D__$(BOARD)__ -o build/main.o src/main.c
	make link



link: build/main.o build/startup_$(BOARD_LOWER)_gcc.o build/system_$(BOARD_LOWER).o
	arm-none-eabi-gcc -T "$(TI_SOURCE)/$(BOARD_LOWER).ld" $(LINK_FLAGS) -o $(OUTPUT_NAME).elf build/*.o


build/startup_$(BOARD_LOWER)_gcc.o: $(TI_SOURCE)/startup_$(BOARD_LOWER)_gcc.S
	arm-none-eabi-gcc -c -mapcs-frame $(COMPILE_FLAGS) -D__$(BOARD)__ -o build/startup_$(BOARD_LOWER)_gcc.o $(TI_SOURCE)/startup_$(BOARD_LOWER)_gcc.S


build/system_$(BOARD_LOWER).o: $(TI_SOURCE)/system_$(BOARD_LOWER).c
	arm-none-eabi-gcc -c -mapcs-frame $(COMPILE_FLAGS) -D__$(BOARD)__ -o build/system_$(BOARD_LOWER).o $(TI_SOURCE)/system_$(BOARD_LOWER).c




# In case you want to re-build your project for some odd reason and start from 
# scratch, but I won't judge you for that
clean:
	rm -rfv build/*.d
	rm -rfv build/*.o
	rm -rfv *.elf
	rm -rfv *.bin
	rm -rfv *.hex


# Getting ready to flash the resulting output file (either ihex or binary)
binary: $(OUTPUT_NAME).elf
	arm-none-eabi-objcopy -O binary $(OUTPUT_NAME).elf $(OUTPUT_NAME).bin

ihex: $(OUTPUT_NAME).elf
	arm-none-eabi-objcopy -O ihex $(OUTPUT_NAME).elf $(OUTPUT_NAME).hex