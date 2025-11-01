---
title: "Building an OS - 1 - Hello world"
---

> Note: This is an almost verbatim transcript of the [Building an OS - 1 - Hello world](https://youtu.be/9t-SPC7Tczc) video (some minor changes have been made where it would make things more clear). If you want to follow the new and improved text tutorial, [check here]({{< ref "building-an-os" >}}).

## Introduction

Hello and welcome! In this tutorial, I will show you what it takes to build an operating system from scratch, so let's jump straight into it!

## The tools

First, let's see what tools we will need. For editing text, any text editor will do; I will be using the _[micro editor](https://micro-editor.github.io/)_, which I really like because it uses common keyboard shortcuts. However, you can use anything you like.

We will use _[make](https://www.gnu.org/software/make/manual/make.html)_ to build our project. _[nasm](https://www.nasm.us/)_ will be our assembler, which we will use to assemble our assembly code.

We will also need some virtualization software. I will use [qemu](https://www.qemu.org/), but you can use any virtualization software you like such as [VirtualBox](https://www.virtualbox.org/), [VMware](https://www.vmware.com/products/workstation-player.html) etc.

I will be using Ubuntu in this tutorial; if you want to follow on Windows, your best option would be to use the Windows Subsystem for Linux. You can find a tutorial on how to set that up in the video description. The second option would be Cygwin which has most of the tools that we need. On MacOS you shouldn't have any trouble finding these tools using [Homebrew](https://brew.sh/).

## Getting started

Let's create a `src` folder in our project, and inside we'll make a file called `main.asm`. The first part of our operating system will be written in a programming language called _assembly_. Later, we will be using C, but right now we don't really have a choice and we really have to use assembly.

So what exactly is this _assembly_ thing? Shortly, the _assembly language_ is the human readable interpretation of machine code. When you compile a program in a programming language such as C or C++, it gets converted into machine code which is the language that the processor understands. Assembly makes it easier for us, humans, to read and write machine code. Higher level programming languages, such as C or C++, need to be translated by the compiler into machine code. This involves many steps, like building an abstract syntax tree, and a huge amount of optimization. Assembly is much simpler, because the instructions simply need to be converted into their machine code representation by a tool called an _assembler_.

An assembly instruction is made up of a _mnemonic_, or a keyword, and a number of parameters which are called _operands_, typically zero, one or two operands.

```nasm
add ax, 7
mov bx, ax
inc ax

mnemonic operand1, operand2, ...
```

An important thing I'd like to mention about the assembly language is that there are differences between different processors. The instructions supported on an x86 processor, that you find in laptops and desktops, are different than instructions supported on an ARM CPU, which is found in smartphones or tablets. Even different processors with the same architecture might have differences; for example SSE is a feature introduced in the Pentium 3 processor line that didn't exist in the Pentium 2 line. However, newer processors easily keep backwards compatibility so that all the programs can still run without any modification. Backwards compatibility for the x86 architecture goes so far back that it can still run software on a modern computer that was designed for the 8086 CPU, the first CPU ever made, using the x86 architecture which was at least 40 years ago.

So, to be clear, we will be writing our operating system for the x86 architecture. This means that we'll be using the x86 assembly language.

## The boot process

So, what happens when you turn on your computer? First the BIOS kicks in performing all sorts of tests, showing a fancy logo and then, the part that's the most important to us... It starts the operating system. How does it do that?

There are actually two ways in which the BIOS can load an operating system. In the first method which is now called _**legacy booting**_ the BIOS loads the first block of data (the first sector) from each boot device into memory, until it finds a certain signature (0xAA55). Once it finds that signature, it jumps to the first instruction in the loaded block; and this is where our operating system starts. The second method is called **_EFI_**, which works a bit differently. In this mode, the BIOS looks for a certain EFI partition on each device, which contains special EFI programs. For the moment, we won't be covering EFI, we will only look at legacy mode.

Now that we know how the BIOS loads our operating system, here's what we need to do: we will write some code, assemble it, and then we will put it in the first sector of a floppy disk. We also need to somehow add that signature that the BIOS requires, after which we can test our operating system. So, let's begin coding...

## Writing the assembly code

We know that the BIOS always puts our operating system at address 0x7C00, so the first thing we need to do is give our assembler this information. This is done using the `org` directive, which tells the assembler to calculate all memory offsets starting at 0x7C00.

```nasm
org 0x7C00
```

Note: changing this line to another number won't make the bios load a different address! It will only tell the assembler that the variables and labels from our code should be calculated with the offset 0x7C00.

Before we continue, I need to explain the difference between a **_directive_** and an **_instruction_**. A **_directive_** is a way of giving the assembler a clue about how to interpret our code. While an instruction is translated into a machine code instruction, a directive won't get translated; it is only giving a clue to the assembler.

Next, we need to tell our assembler to emit 16-bit code. As I mentioned before, any x86 CPU must be backwards compatible with the original 8086 CPU. So, if an operating system that was designed for the 8086 is run on a modern CPU, it still needs to think that it's running on an 8086. Because of this, the CPU always starts in 16-bit mode. `bits` is also a directive which tells the assembler to emit 16-bit code.

```nasm
bits 16
```

Note: Writing `bits 32` won't make the processor run in 32-bit mode! It is only a directive which tells the assembler to emit 32-bit code.

Now, I'll define the `main` label to mark where our code begins. For now, we just want to know that the BIOS loads our operating system correctly, so I'll only write a `hlt` (halt) instruction which halts (stops) the processor. In certain cases, the CPU can start executing again, so I'll just create another `.halt` label, and then jump to it. This way, if the CPU ever starts again, it will be stuck in an infinite loop. It's not a good idea to allow the processor to continue executing beyond the end of our program.

```nasm
main:
    hlt

.halt
    jmp .halt
```

Our program is almost done. All that's left to do is add that signature that the BIOS requires. The BIOS expects that the last two bytes of the first sector are 0xAA55. We will be putting our program on a standard 1.44 MB floppy disk image, where one sector has 512 bytes. We can ask _nasm_ to emit bytes directly by using the `db` directive, which stands for "declare constant byte". The `times` directive can be used to repeat instructions or data. Here, we use it to pad our program so that it fills up to 510 bytes, after which we declare the two byte signature. In nasm, the `$` symbol can be used to obtain the assembly position of the beginning of the current line, and the `$$` sign gives us the position of the beginning of the current section. In our case, `$-$$` will give us the length of the program so far, measured in bytes. Finally we declare the signature. `dw` is a directive similar to `db`, but it declares a two byte constant, which is generally referred to as a "word".

```nasm
times 510-($-$$) db 0
dw 0AA55h
```

With this, we have successfully written our first operating system! So far, it doesn't really do anything but stop the processor. Let's test it if it works!

## Writing the makefile

I created a `build` directory to keep things organized. For building the project, I will create a `Makefile`. I added a rule to build the `main.asm` code using nasm, and output in a binary format. I also added a rule to build the disk image, where I simply take the binary file previously built, and pad it with zeros (with the `truncate` command) until it has 1.44 megabytes.

{{< code file="Makefile" lang="make" >}}
ASM=nasm

SRC_DIR=src
BUILD_DIR=build

$(BUILD_DIR)/main_floppy.img: $(BUILD_DIR)/main.bin
    cp $(BUILD_DIR)/main.bin $(BUILD_DIR)/main_floppy.img
    truncate -s 1440k $(BUILD_DIR)/main_floppy.img

$(BUILD_DIR)/main.bin: $(SRC_DIR)/main.asm
    $(ASM) $(SRC_DIR)/main.asm -f bin -o $(BUILD_DIR)/main.bin
{{< /code >}}

## The first test

Finally, we can test our little operating system. You can use any virtualization software you want, such as VirtualBox, VMWare etc. I use `qemu` because it's really easy to setup, and it can be used from a command line.

```bash
$ qemu-system-i386 -fda build/main_floppy.img
```

As you can see, the system boots from floppy, and then it does nothing, exactly as we expected! So far, our operating system does nothing, and does it perfectly!!!

![First boot screenshot](/images/transcripts/first-boot.png)

## Hello world

Now that we know it works, let's go back to the code and print a "Hello world" message to the screen. Before I start explaining how you can do that, I need to explain some basic concepts about the x86 architecture.

### CPU registers

All processors have a number of registers, which are really small pieces of memory that can be written and read very fast, and are built into the CPU. Here is a diagram of all the registers on an x86 CPU:

![Table of x86 registers](/images/table_of_x86_registers.svg)

There are several types of registers:

- the general-purpose registers can be used for almost any purpose (RAX, RBX, RCX, RDX, R8-R15 including their smaller counter parts, EAX, AX, AL, AH etc)
- the index registers (RSI, RDI) are usually used for keeping indices and pointers; they can also be used for other purposes
- the program counter (RIP) is a special register which keeps track of which memory location the current instruction begins at
- the segment registers (CS, DS, ES, FS, GS, SS) are used to keep track of the currently active memory segments (which I will explain in just a moment)
- there is also a flags register (RFLAGS) which contains some special flags set by various instructions
- there are a few more special purpose registers, but I will only introduce them when we need them

### Real memory model

Now let's talk a bit about RAM. The 8086 CPU had a 20-bit address bus, which meant that you could access up to 2^20, or about 1 MB of memory. At the time, typical computers had around 64 to 128 KB, so the engineers at Intel thought this limit was huge. For various reasons, they decided to use a _segment and offset addressing scheme_ for addressing memory.

```
               0x1234:0x5678
              segment:offset
```

In this scheme, you use two 16-bit values, the **_segment_** and the **_offset_**. Each segment contains 64 KB of memory, where each byte can be accessed by using the offset value. Segments overlap every 16 bytes.

<img src="/images/transcripts/segment-addressing.png" alt="Segment addressing diagram" style="width: 50%;">

This means that you can convert a segment:offset address to an absolute address by shifting the segment four bits to the left (or multiplying it by 16), and then adding the offset.

```c
linear_address = segment << 4 + offset;
// or
linear_address = segment * 16 + offset;
```

This also means that there are multiple ways of addressing the same location in memory. For example, the absolute address 0x7C00 (where the BIOS loads our operating system) can be written as any combination that you can see on the screen:

```
segment:offset     linear_address
 0x0000:0x7C00         0x7C00
 0x0001:0x7BF0         0x7C00
 0x0010:0x7B00         0x7C00
 0x00C0:0x7000         0x7C00
 0x07C0:0x0000         0x7C00
```

There are some special registers which are used to specify the actively used segments:

- `CS` contain the code segment, which is the segment the processor executes code from. The `IP` register (the program counter) only gives us the offset!
- `DS` and `ES` are data segments. Newer processors introduced additional data segments `FS` and `GS`
- `SS` contains the current stack register

In order to access (read or write) any memory location, its segment needs to be loaded into one of these registers, by setting the corresponding register. The code segment can only be modified by performing a jump.

Now, how do we reference a memory location from assembly? We use this syntax:

```nasm
[segment : base + index * scale + displacement]
```

Where:

- segment: one of CS, DS, ES, FS, GS, SS. Default: DS (SS if BP is used as base)
- base
  - 16-bit: BP or BX
  - 32/64-bit: any general purpose register
- index:
  - 16-bit: SI or DI
  - 32/64-bit: any general purpose register
- scale (32/64-bit only): 1, 2, 4 or 8
- displacement: a signed constant number

The processor is capable of doing some arithmetic for us, as long as we use this expression.

In 16-bit mode, there are a few limitations because that's how the 8086 CPU was originally designed. This was probably done to keep the complexity and cost down. Another example of one such limitation is that we can't write constants to the segment registers directly, we have to use an intermediary register. With the introduction of the 386 processor just a few years later, 32-bit mode was introduced which pretty much rendered 16-bit mode obsolete. A lot of newer CPU features were simply not added to the 16-bit mode, because it is obsolete and only exists for backwards compatibility. However, it is still useful to learn, because most of the things that apply to a 16-bit mode also apply to 32-bit and 64 bit modes. The main use today of 16-bit mode is in the startup sequence; most operating systems switch to 32 or 64-bit mode immediately after starting up. We will do the same thing in a future video, but we can't just yet, as we are limited to the first sector of a floppy disk (512 bytes) which is very little space. Once we are able to load a from the disk, we can do a lot more.

All operating systems have to do the same thing in order to boot, but until we get there, let's get back to referencing our memory locations. So, I already talked about the base and index operands. The scale and displacement operands are numerical constants; the scale can only be used in 32 and 64-bit modes, and it can only have a value of 1, 2, 4 or 8. The displacement can be any signed integer constant.

All the operands in a memory reference expression are optional, so you only have to use whatever you need.

#### Examples

##### Example 1:

```nasm
var: dw 100

    mov ax, var     ; copy offset to ax
    mov ax, [var]   ; copy memory contents of ds:var to ax
```

First, I defined a label which points to a word having the value `100`.

The first instruction `mov ax, var` puts the offset of the label into the ax register.

The the second instruction `mov ax, [var]` copies the memory contents that our label points to. Since we didn't specify a segment register, DS is going to be used. We haven't used the base, index or scale, but only a constant, which is the offset denoted by the "var" label. In assembly, labels are simply constants which point to specific memory offsets.

##### Example 2:

```nasm
array: dw 100, 200, 300

    ; read third element in array
    mov bx, array
    mov si, 2 * 2
    mov ax, [bx + si]
```

Here's a more complicated example, where we want to read the third element in an array. We put the offset of the array into BX, and the index of the third element in SI. Since we use zero-based indexing, the third element is at `array[2]`; each element in the array is a word, which is 2 bytes wide, so we put in SI the value 4.

Note: You can see here that we use the multiplication symbol. The assembler is capable of calculating the result of constant expressions, and put the result in the resulting machine code. However, you can't write `mov bx, ax * 2`. `AX` is not known at compile time, so it is not a constant. To perform this multiplication, you have to use the `MUL` (multiply) instruction. Referencing memory is the only place where you can put registers in an expression!

Finally, we put into AX the third element in the array, by referencing the memory location at BX + SI. BX is our base register, and SI is our index register.

### Back to the OS - the initialization

Back to our operating system, the code segment register has been set up for us by the BIOS and it points to segment 0. There are some BIOSes out there which actually jump to our code using a different segment and offset such 0x07C0:0x0000, but the standard behavior is to use 0x0000:0x7C00. We don't know if DS and ES are properly initialized, so this is what we have to do next. Since we can't write a constant directly to a segment register, we have to use an intermediary register; we will use AX. The MOV (move) instruction copies data from the source on the left side to the destination on the right side.

```nasm
main:
    ; setup data segments
    mov ax, 0           ; can't set ds/es directly
    mov ds, ax
    mov es, ax

    ; setup stack
    mov ss, ax
    mov sp, 0x7C00      ; stack grows downwards from where we are loaded in memory
```

We also set up the stack segment (SS) to 0, and the stack pointer (SP) to the beginning of our program. So what exactly is this stack?

The stack is a piece of memory that we can access in a "first in last out" manner, using the PUSH and POP instructions. The stack also has a special purpose when using functions. When you call a function, the return address is added to the stack, and when you return from a function, the processor will read the return address from the stack and then jump to it.

Another thing to note about the stack is that it grows downwards! SP points to the top of the stack. When you push something, SP is decremented by the number of bytes pushed, and then the data is written to memory. This is why we set up the stack to point to the start of our operating system: because it grows downwards. If we set it up to the end of our program, it would overwrite our program. We don't want that, so we just put it somewhere where it won't overwrite anything. The beginning of our operating system is a pretty safe spot.

Now we'll start coding a `puts` function which prints a string to the screen.

Note: Always document your assembly functions!

```nasm
start:
    jmp main

;
; Prints a string to the screen
; Params:
;   - ds:si points to string
;
puts:

    ; .......


main:
```

Our function will receive a pointer to a string in `DS:SI` and it will print characters until it encounters a null character. Because I decided to write the function above `main`, I have to add a jump instruction above, so `main` is still the entry point to our program.

First, we push the registers that we're going to modify to the stack, after which we enter the main loop.

```nasm
puts:
    ; save registers we will modify
    push si
    push ax
    push bx

.loop:
    lodsb               ; loads next character in al
```

The `lodsb` (load string byte) instruction loads a byte from the address `DS:SI` into the AL register, and then increments `SI`.

Next, I wrote the loop exit condition; the `or` instruction performs a bit-wise "or" and stores the result in the left operand, in this case `AL`. OR-ing a value to itself won't modify the value at all, but it will modify is the `FLAGS` register. If the result is 0, the "zero" flag (ZF) will be set.

```nasm
    or al, al           ; verify if next character is null?
    jz .done            ; exit condition

    ; todo .....

    jmp .loop

.done:
    pop bx
    pop ax
    pop si
    ret
```

The next instruction, `JZ`, is a conditional jump which will jump to the `.done` label if the zero flag is set. So, essentially, if the next character is `null`, we jump outside the loop.

After exiting the loop, we pop the registers we previously pushed in reverse order, and then we'll return from this function. So far, our function takes a string, iterates every character until it encounters the `null` character, and then exits. What's left to do is to print the character to the screen. The way we can do that is by using the BIOS. As the name suggests, the **_BIOS_** or the **_Basic Input/Output System_** does more than just start the computer. It also provides some very basic functions, which allow us to do some very basic stuff, such as writing text to the screen. So, how exactly do we call the BIOS to print the character for us? The answer is that we use **_interrupts_**.

## Interrupts

An interrupt is a signal which makes the processor stop whatever it is doing to handle that event. There are 3 possible ways of triggering an interrupt:

- Through **_an exception_**; an exception is generated by the CPU if a critical error is encountered, and it cannot continue executing. For example, dividing by zero will trigger an interrupt. Operating systems can use these interrupts to stop the misbehaving process, or to attempt to restore it to working order.
- **_Hardware_** can also trigger interrupts. For example, when a key is pressed on the keyboard, or when the disk controller finished performing an asynchronous read.
- From code, through the **_INT instruction_**. Interrupts are numbered from 0 to 255, so the `INT` instruction requires a parameter indicating the interrupt number to trigger.

The BIOS installed some interrupt handlers for us, so that we can use its functionality. Typically, the BIOS reserves an interrupt number for a category of functions, and the value in the `AH` register is used to choose between the available functions in that category.

```
Examples of BIOS interrupts:

INT 10h -- Video
INT 11h -- Equipment check
INT 12h -- Memory size
INT 13h -- Disk I/O
INT 14h -- Serial communication
INT 15h -- Cassette
INT 16h -- Keyboard

............
```

To print text to the screen, we will need to call [interrupt 10h](https://en.wikipedia.org/wiki/INT_10H) which contains the video services category. By setting `AH` to `0Ah`, we will call the "write text in teletype mode" function. Here's a detailed description of this function:

```
VIDEO - TELETYPE OUTPUT

AH = 0Eh
AL = character to write
BH = page number
BL = foreground color (graphics modes only)

Return:
Nothing

Desc: Display a character on the screen, advancing the cursor and scrolling the screen as necessary

Notes: Characters 07h (BEL), 08h (BS), 0Ah (LF), and 0Dh (CR) are interpreted and do the expected things.
IBM PC ROMs dated 1981/4/24 and 1981/10/19 require that BH be the same as the current active page

BUG: If the write causes the screen to scroll, BP is destroyed by BIOSes for which AH=06h destroys BP

Source: http://www.ctyme.com/intr/rb-0106.htm
```

What we need to do in order to call this function is to set:

- AH to 0Eh
- AL to the ASCII character that we want to print
- BH to the page number (which is 0)
- BL (the foreground color) is only used in graphics mode, so we can ignore it because we're currently running in text mode.

```nasm
    mov ah, 0x0E        ; call bios interrupt
    ; al is already set by lodsb
    mov bh, 0           ; set page number to 0
    int 0x10
```

Finally let's add a string containing "Hello world", followed by a new line. To add a new line, you need to print both the line feed and the carriage return characters. I created an awesome macro so that I don't have to remember the hex codes for these characters every time. To declare the string we use the DB directive.

```nasm
%define ENDL 0x0D, 0x0A
msg_hello: db 'Hello world!', ENDL, 0
```

All that's left to do is to set DS:SI to the address of the string, and then call `puts`.

```nasm
    ; print hello world message
    mov si, msg_hello
    call puts
```

Let's now test our program:

```bash
$ make
$ qemu-system-i386 -fda build/main_floppy.img
```

And the result:

![Hello World output](/images/transcripts/hello-world-output.png)

## Conclusion

Great! So, we have successfully written a tiny operating system which can print text to the screen! This was a lot of work, and we learned a lot of new stuff about how computers work. We'll continue the next time when we will improve our assembly skills and learn some new stuff, by extending our operating system to print numbers to the screen. After that, we will get into the complex task of loading stuff from the disk.

Thank you for watching and see you the next time! Bye bye!
