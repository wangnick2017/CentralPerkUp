#!/bin/sh
set -e
rpath="/opt/riscv/bin/"
${rpath}riscv32-unknown-linux-gnu-gcc -o ${1%.*}.o -I . -c $1 -O2 -march=rv32i -mabi=ilp32 -Wall
${rpath}riscv32-unknown-linux-gnu-gcc -o system.o -c system.c -O2 -march=rv32i -mabi=ilp32 -Wall
${rpath}riscv32-unknown-linux-gnu-as -o rom.o -march=rv32i rom.s
#${rpath}riscv32-unknown-linux-gnu-ld -T memory.ld rom.o ${1%.*}.o system.o -L $rpath/../riscv32-unknown-linux-gnu/lib/ -L $rpath/../lib/gcc/riscv32-unknown-linux-gnu/8.2.0/ -lc -lgcc -lm -lnosys -o ${1%.*}.om
${rpath}riscv32-unknown-linux-gnu-ld -T memory.ld rom.o ${1%.*}.o system.o -L $rpath/../riscv32-unknown-linux-gnu/lib/ -L $rpath/../lib/gcc/riscv32-unknown-linux-gnu/8.2.0/ -lgcc -o ${1%.*}.om
${rpath}riscv32-unknown-linux-gnu-objcopy -O verilog ${1%.*}.om ${1%.*}.dat
