---
title: "Part 3: Introduction to x86 assembly"
---

_Assembly_ is a class of low level programming languages in which instructions map directly to machine code instructions that the CPU can understand. In other words, an assembly language is the human readable equivalent of machine code.

While _Assembly_ languages share a lot of similarities, they are architecture dependent. _x86 Assembly_ is different from _ARM Assembly_. Because of this, assembly is far less portable than higher level languages, such as C: you can write a C program that can be run on both x86 and ARM (after recompilation), but this is not possible with _Assembly_.

For convenience, in the rest of this series, we will refer to _x86 Assembly_ as simply _Assembly_, but it is important to understand the difference.

_Assembly_ code is translated into machine code by a tool called an _assembler._ The main difference between an _assembler_ and a _compiler_ is that an assembler simply translates the human readable instructions into machine code, while compilers have a lot more work to do; an instruction in a high level language such as C might translate into many machine code instructions.

## Instruction syntax

Assembly instructions have the following syntax:

`mnemonic operand1, operand2, operand3...`

The mnemonic is a keyword that represents a specific instruction. The number of operands depends on the instruction.

A lot of instructions, such as `mov` which copies data from one place to another, or `add` which adds up numbers, will also use operand 1 as the destination. For example:

`add eax, 20`

This will replace the contents of `eax` with the result of `eax + 20`. Written in C, this code would look like this:

`eax = eax + 20;`

### Intel vs AT&T syntax

What I have shown so far is using the Intel syntax. There are in fact 2 flavors of x86 assembly, one developed by Intel, and the other developed by AT&T Bell Labs. _GAS_, the assembler that comes with _GCC_, as well as the _GDB_ debugger will use the AT&T syntax by default, but it can be changed. _NASM_, which is the assembler we will use, uses the Intel syntax. Here is a small example, highlighting the main differences:

#### Intel

```nasm
mov eax, 5
add esp, 24h
mov eax, [ebx + ecx*4 + offset]
```

- Destination always on the left
- No prefixes for registers and constants
- Instruction size is determined automatically based on operand size

#### AT&T

```nasm
movl $5, %eax
addl $0x24, %esp
movl offset(%ebx,%ecx,4), %eax
```

- Destination always on the right
- Registers are prefixed with %, constants with $
- Mnemonics suffixed with a letter indicating the size of the operands

You can read more details about this subject on Wikipedia. In this tutorial, we will only use the Intel syntax which in my personal opinion is easier to read.

## Some important instructions

{{< wip >}}
This section is currently being written. The article covers the basics of x86 assembly syntax but is missing detailed instruction references.
{{< /wip >}}
