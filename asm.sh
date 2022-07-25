#!/usr/bin/bash

nasm -f elf -g $1.asm
ld -m elf_i386 $1.o -o $1
./$1
