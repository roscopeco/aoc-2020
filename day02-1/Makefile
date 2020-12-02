# Makefile for AoC 2020 solutions
# 
# Copyright (c)2020 Ross Bamford
# See LICENSE

EXTRA_CFLAGS?=
SYSINCDIR?=../../rosco_m68k/code/software/libs/build/include
SYSLIBDIR?=../../rosco_m68k/code/software/libs/build/lib
LIBS=-lstart_serial
DEFINES=
LDFLAGS=-T $(SYSLIBDIR)/ld/serial/rosco_m68k_program.ld -L $(SYSLIBDIR) \
				-Map=$(MAP)
ASFLAGS=-Felf -m$(CPU) -quiet $(DEFINES)
CC=m68k-elf-gcc
LD=m68k-elf-ld
AS=vasmm68k_mot
RM=rm -f

KERMIT=kermit
SERIAL?=/dev/modem
BAUD?=9600

# Output config
BINARY_BASENAME=solution
BINARY_EXT=bin
MAP=$(BINARY_BASENAME).map
BINARY=$(BINARY_BASENAME).$(BINARY_EXT)

OBJECTS=kmain.o

ifeq ($(MC68020),true)
DEFINES:=-DMC68020
CPU=68020
else
CPU=68010
endif

%.o : %.c
	$(CC) -c $(CFLAGS) $(EXTRA_CFLAGS) -o $@ $<

%.o : %.S
	$(AS) $(ASFLAGS) -o $@ $<

$(BINARY) : $(OBJECTS)
	$(LD) $(LDFLAGS) $^ -o $@ $(LIBS)
	chmod a-x $@

.PHONY: all clean load

all: $(BINARY)

clean: 
	$(RM) $(OBJECTS) $(BINARY) $(BINARY_ODD) $(BINARY_EVEN) $(MAP)

load: $(BINARY)
	kermit -i -l $(SERIAL) -b $(BAUD) -s $(BINARY)
