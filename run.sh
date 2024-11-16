#!/usr/bin/bash

nasm -f elf64 t3.asm && ld -o t3 t3.o && ./t3
