---
title: "Building an OS - 2 - The disk"
draft: false
---

Watch the video: [Building an OS - 2 - The disk](https://www.youtube.com/watch?v=srbnMNk7K7k)

## Introduction

Hello and welcome! This is part two of the Building an Operating System series. Today we'll learn how to load data from a floppy disk.

### Corrections from Part 1

Before talking about today's topic, I would like to correct some mistakes I made in the first episode:

First of all, I said that the MOV instruction moves from the left to the right, which is incorrect. MOV moves from right to left. You can think of it as an assignment in C: the destination is on the left side and the source is on the right side.

Also, in the "referencing a memory location" section, I said that when the segment is not specified, DS is used by default. This is mostly correct. However, as a viewer pointed out, when the base register is BP, SS will be the default.

## The Problem: 512 Bytes Isn't Enough

So far, we've been limited to the first sector of a floppy disk, which is 512 bytes large. This is very little space. We haven't reached the limit yet, but after today's episode, we won't be far from it.

Our number one priority is to implement some code which will load the rest of the operating system into memory. What this means is that we will have to split our operating system into two modules—the first one will load the second one.

All operating systems are actually split this way, because 512 bytes is not enough to fit even the most basic functions of an operating system.

## What is a Bootloader?

The first module is called a **bootloader**, and generally speaking, it has several functions:

- It loads the most essential components of the operating system into memory
- It puts the computer in the state that the kernel expects it to be in
- It collects some basic information about the system

Depending on the operating system, the bootloader can be very simple or very complex.

Older operating systems like MS-DOS run in 16-bit real mode (the mode we're using right now), so the bootloader's job was quite simple: to just load some binary and run it.

More modern operating systems typically expect the bootloader to make the switch to 32-bit protected mode for them, and also collect some system information. We haven't talked a lot about 32-bit protected mode yet, but we will get there, I promise.

However, one of its main limitations is that the BIOS functions that we talked about in Part 1 can no longer be used. Some of these functions are really important, as they provide us with critical information. For example, there is a function which shows us the memory layout: which parts of the memory are safe to use, and which parts are reserved by hardware.

Calling these functions is not possible once we are in 32-bit protected mode, so the responsibility falls upon the bootloader to collect all the required information before it starts the main kernel.

> **Note:** By "not possible," I mean possible, but we need to set up a lot of stuff until we get there, and we need that information a lot sooner than that, which is why I say it's not possible.

## Floppy Disks and File Systems

Now that we know what we're going to be working on, let's talk a bit about floppy disks.

### Why Floppy Disks in 2021?

That's a very good question! When getting started working on an operating system, a floppy disk is the simplest form of disk storage we can work with:

- It is universally supported by all BIOSes as well as all virtualization software
- Creating and working with disk images is very easy
- The FAT12 file system is rudimentary simple

All of these make it ideal for making operating systems, at least until we learn the basics and we can move to other storage devices.

### Simple Approach vs. File Systems

The simplest way in which we could use a disk would be to have the bootloader in the first sector (the boot sector) and the rest of the operating system starting from sector 2. This would be quite easy to implement: our bootloader would read a number of sectors into memory and then start executing them.

The problem with this approach is that we wouldn't be able to use the disk for storing any files, which is not very useful. We could design our own file system around that, but it's probably a better idea to use an existing standard one like FAT, EXT, or NTFS, so that we can easily exchange data between our operating system and other operating systems like Windows and Linux.

## Setting Up the Project

Let's get back to the code and continue from where we left off in Part 1. This time, I decided to use Visual Studio Code as the editor with the [x86_64 Assembly extension](https://marketplace.visualstudio.com/items?itemName=13xforever.language-x86-64-assembly) installed.

### Splitting the Code into Modules

Since we want to split our code into two modules, let's do that right now. I created two different directories in our source directory: one for the bootloader and one for the kernel. I put the same source file that we worked on in Part 1 in both folders.

[CODE: Directory structure showing src/bootloader/ and src/kernel/]

### Updating the Makefile

Next, we need to make some changes to our Makefile to keep things organized.

I declare some phony targets:

[CODE: Makefile phony targets]

This way we can keep our Makefile cleaner by referring to various modules using their names rather than their output file names.

Then I added a rule to tell Make that the phony floppy image target depends on the actual file `main_floppy.img`. In the floppy image dependencies, I replaced `main.bin` with the `bootloader` and `kernel` targets.

[CODE: Makefile floppy image dependencies]

Next, I added the rules for building the bootloader. The `always` target will be used for creating the build directory if it doesn't exist, so we don't get compilation errors if the directory doesn't exist.

For the build rules, it's really simple—we just call NASM like we did before.

[CODE: Bootloader build rules]

For now, to build the bootloader and the kernel, the steps are identical, so I just added the same rules for the kernel.

[CODE: Kernel build rules]

Next, I created the `always` target which simply creates the build directory if it doesn't exist, and the `clean` target will simply delete everything in the build folder.

[CODE: always and clean targets]

Let's give this a go and see what happens.

[CODE: make command output showing error]

Looks like we got an error when creating the floppy image. Ah yes, I forgot to change the file names in the `main_floppy.img` rules.

## Creating a FAT12 Disk Image

Talking about the floppy image, let's modify the way we create the image so that we actually create a FAT12 disk image.

First, we need to generate an empty 1.44 megabyte file. We can do that using the `dd` command with the block size set to 512 and the block count set to 2880:

[CODE: dd command for creating empty image]

The next step is to create the file system using the `mkfs.fat` command. The `-F 12` argument tells it to use FAT12, and `-n` is used for the label, which doesn't really matter since we will overwrite it anyway.

[CODE: mkfs.fat command]

Next, we need to put the bootloader in the first sector of the disk. The simplest way to do that is to use the `dd` command with the `conv=notrunc` option, which tells dd not to truncate the file—otherwise we will lose the rest of the image.

[CODE: dd command for writing bootloader]

Now that we have a file system, we can copy the files to the image. One option could be to mount the image, but I don't really like doing that because we would have to run the image generation with elevated privileges.

Fortunately, there's a collection of tools called **mtools** which contains a bunch of utilities that we can use to manipulate FAT disk images directly without having to mount them. To copy the `kernel.bin` file to the disk, we can use the `mcopy` command:

[CODE: mcopy command]

Our Makefile is now finished, so let's give it another go.

[CODE: make command output with mcopy error]

And we're getting another error now. `mcopy` is complaining that the disk image is not valid. What happened?

### The Problem: Overwriting FAT12 Headers

The issue here is that we have overwritten the first sector of the image with our bootloader. This section contains some important headers used by FAT12, so by overwriting them we have broken the file system.

Can we fix this? Yes! We just need to add these headers to our bootloader.

## BIOS Parameter Block and Extended Boot Record

Going to the article about the FAT file system on the OSDev wiki, there's [this section](http://wiki.osdev.org/FAT#BPB_.28BIOS_Parameter_Block.29) which describes all the fields that are required for a valid FAT file system. What we need to do is add all of them to our bootloader.

To help us figure out what the values of these headers should be, I have created a `test.img` disk image using the same steps as in the Makefile, but without overwriting the boot sector.

[IMAGE: Hex editor showing test.img]

By opening the file using a hex editor, we can figure out what the value of each field should be set to.

### Adding the Headers to Our Bootloader

Let's begin working on our bootloader. Looking at the documentation, there are two sections that we need to add, each containing a number of fields.

#### BIOS Parameter Block

The first one is called the **BIOS Parameter Block**. Here are all the fields we need to add for a standard 1.44 MB floppy disk:

| Field | Size | Value (1.44 MB Floppy) | Description |
|-------|------|------------------------|-------------|
| Jump instruction | 3 bytes | `jmp short start` + `nop` | Short jump to bootloader code |
| OEM Identifier | 8 bytes | `"MSWIN4.1"` | Typically set by the formatting tool (we use this for compatibility) |
| Bytes per sector | 2 bytes (word) | 512 (0x0200) | Standard sector size |
| Sectors per cluster | 1 byte | 1 | How many sectors per cluster |
| Reserved sectors | 2 bytes (word) | 1 | Number of reserved sectors (including boot sector) |
| FAT count | 1 byte | 2 | Number of File Allocation Tables |
| Directory entry count | 2 bytes (word) | 224 (0xE0) | Maximum number of root directory entries |
| Total sectors | 2 bytes (word) | 2880 | Total sectors (2880 × 512 = 1.44 MB) |
| Media descriptor type | 1 byte | 0xF0 | Indicates 3.5-inch floppy disk |
| Sectors per FAT | 2 bytes (word) | 9 | Size of each FAT |
| Sectors per track | 2 bytes (word) | 18 | Sectors per track (CHS) |
| Head count | 2 bytes (word) | 2 | Number of heads (CHS) |
| Hidden sectors | 4 bytes (dword) | 0 | Number of hidden sectors |
| Large sector count | 4 bytes (dword) | 0 | Used when total sectors > 65535 |

> **Note:** Remember that multi-byte values are stored in **little-endian** format. For example, 512 (0x0200) is stored as `00 02` in memory.

[CODE: BIOS Parameter Block fields in bootloader]

#### Extended Boot Record

The **Extended Boot Record** contains additional metadata:

| Field | Size | Value | Description |
|-------|------|-------|-------------|
| Drive number | 1 byte | 0 | Drive number (0 for floppy A:) |
| Reserved | 1 byte | 0 | Reserved byte |
| Signature | 1 byte | 0x28 or 0x29 | Extended boot signature |
| Volume ID | 4 bytes (dword) | Any value | Serial number (can be anything) |
| Volume label | 11 bytes | Padded with spaces | Disk volume label |
| System ID | 8 bytes | `"FAT12   "` | File system type (padded with spaces) |

[CODE: Extended Boot Record fields in bootloader]

Now that we added all the required headers, we can test if `make` works.

[CODE: make command output - success]

And it does! We can also verify that the disk contains our kernel by running the `mdir` command:

[CODE: mdir command output]

## Understanding Disk Layout: CHS vs LBA

Before beginning to implement our disk reading operation, it is useful to understand how data is laid out on these disks. This applies to all forms of disks: floppy, CDs, DVDs, and hard drives.

[IMAGE: Diagram of disk platter]

Looking at the round disk, if we divide it into rings, each ring represents a **track** (or a **cylinder**).

Another way of dividing the platter is into pizza slices—these are called **sectors**.

Floppy disks, as well as hard disks, can store data on both sides of the platter, so we call each side a **head**. Hard disks can also have multiple platters, in which case we count each side of each platter as a head.

### CHS Addressing

To read or write something, we need a way to tell the disk controller where our data is. We can do that by giving it:
- The cylinder number
- The head number
- The sector number

This addressing scheme is called **Cylinder-Head-Sector** or **CHS** scheme.

While this scheme might make sense when you need to determine physically where the data is located on the disk, it is not very useful for us. When working with disks, we don't really care where the data is physically located—we only care if it's at the beginning of the disk, the middle, or the end.

### LBA Addressing

For that, we can use the **Logical Block Addressing** scheme, or **LBA**. Instead of a triplet of numbers, you only need one single number to reference a block on the disk.

Unfortunately, the BIOS function we will use only supports CHS addressing, so we will have to make the conversion ourselves.

> **Note:** Another thing I'd like to mention is that in most modern disks, the physical layout of the data has gotten a lot more complex, and these controllers only pretend to have cylinders, heads, and sectors to maintain compatibility with this legacy addressing scheme. But they have their own methods of determining the physical location of the data.

### LBA to CHS Conversion Formula

In the CHS scheme, the cylinder and head are indexed from 0, but the sector starts from 1.

Taking this into consideration, we can come up with the following formulas for making the conversion.

We have two constants:
- $SPT$ = **Sectors per track** (or sectors per cylinder): How many sectors we can fit in a single track on a single side of the platter
- $HPC$ = **Heads per cylinder**: The number of faces the entire disk has

The conversion formulas are:

$$
\text{sector} = (LBA \bmod SPT) + 1
$$

$$
\text{head} = \left\lfloor \frac{LBA}{SPT} \right\rfloor \bmod HPC
$$

$$
\text{cylinder} = \left\lfloor \frac{LBA}{SPT \times HPC} \right\rfloor
$$

Where:
- $\bmod$ is the modulo (remainder) operation
- $\lfloor x \rfloor$ represents integer division (floor division)

For our 1.44 MB floppy: $SPT = 18$ and $HPC = 2$

Let's write this into assembly.

## Implementing LBA to CHS Conversion

We will write a function which will take the LBA address in the AX register. To make things easier for us, we will store the result exactly how the BIOS function expects us to:

- The cylinder will be in CX, bits 6 to 15
- The sector will be in CX, bits 0 to 5
- The head number will be in DH

[CODE: lba_to_chs function signature]

We can begin by dividing the logical block address stored in AX by the number of sectors per track. That number is a word, so we need to clear DX because the DIV instruction divides DX:AX by the word operand.

[CODE: First division]

After this division, we will have the result in AX and the remainder in DX. To finish calculating the sector, we need to increment the remainder by 1 and then we will put it in CX, which is where the output should be.

[CODE: Sector calculation]

Next, we perform a second division by the number of heads per cylinder. This will give us the cylinder in AX and the head in DX.

[CODE: Second division]

Now we just need to shuffle the results so they are in the correct output registers.

Since DL is the lower 8 bits of DX, we can simply move from DL to DH so that the head number is now in DH.

[CODE: Head assignment]

The cylinder is a bit weird because it is split.

[IMAGE: Diagram showing CX register layout with cylinder and sector]

This is what the CX register should look like. So we need to move the lower 8 bits into CH, which is the upper half of CX. For the upper 2 bits, we can shift them to the left by 6 positions and then OR the result to the CL register, which already contains the sector number.

[CODE: Cylinder bit manipulation]

Now, to be nice, we will save the registers that we modify and are not part of the output. So we save AX and DL by pushing them to the stack, and when everything is done, restore them. But since we can't push 8-bit registers to the stack, we push the whole DX, and when we pop, we only restore DL.

[CODE: Register preservation]

Finally, we can return from this method.

[CODE: ret instruction]

## Implementing Disk Read Function

Next, we will write a method that reads from a disk.

As parameters, we will have:
- **AX:** The logical block address
- **CL:** The number of sectors to read
- **DL:** The drive number
- **ES:BX:** A memory location where we will store the data

[CODE: disk_read function signature]

The first thing we need to do is call our conversion function. But since the function will overwrite the contents of CX (which contains the number of sectors to read), we should save it first by pushing it to the stack.

[CODE: push cx / call lba_to_chs]

Let's quickly look at the function we want to call: the "read sectors from drive" function (INT 13h, AH=02h), and check all the parameters:

- Cylinder, sector, head, drive, and memory destination should already be set
- All that's left to do is set the number of sectors to read in AL and 0x02 in AH

The sector count is saved to the stack, so we pop it into AX and then set AH:

[CODE: pop ax / mov ah, 02h]

But now we can call the interrupt 13h.

### Handling Unreliable Floppy Disks

In a virtual environment, this should work perfectly, but unfortunately in the real world, floppy disks tend to be pretty unreliable. To address that, the documentation recommends us to retry the read operation at least three times.

So let's add that. First, let's set the number of times we want to retry in a register that we haven't used yet—DI—and then begin a loop.

[CODE: Retry loop setup]

We don't really know what registers the BIOS interrupt will overwrite, so we save all of them to the stack using `pusha`.

There is also another quirk of some BIOSes: they don't properly set the carry flag, so we set it ourselves (`stc`).

This is how we can check the result of the operation: if the carry flag is cleared, that means that the operation has succeeded, so we can jump out of the loop.

[CODE: jnc .done]

Now we can restore the registers using `popa`.

If the operation failed, we need to reset the floppy controller, so we will write a method to do that.

[CODE: call disk_reset]

Next, we decrement DI and check the loop condition. If DI is not yet zero, we jump back to the beginning of the loop.

[CODE: dec di / jnz .retry]

If we exit the loop, that means that all of our attempts have been exhausted and the operation still failed, so we will jump to another place which will simply display an error message and stop the boot process.

[CODE: Error handling - display message, wait for keypress, reboot]

To make it nicer, I call this code that calls interrupt 16h with function 0, which waits for a keypress, after which I jump to the address 0xFFFF, which is where the BIOS starts, effectively rebooting the system.

As a last thing, I saved the registers that were modified to the stack and restore them before returning.

[CODE: Register preservation and ret]

## Implementing Disk Reset

The disk reset method is really simple. It only has one parameter: the drive number in DL.

All we need to do is call interrupt 13h with the AH register set to 0. This will reset the disk controller.

[CODE: disk_reset function]

If the operation fails, just like before, we jump to the same floppy error label that prints the error message.

## Testing the Code

After writing all this code, let's give it a try and see if it works.

Let's go back to the main function and try to read some data from the disk.

The BIOS should set the drive number from which it loaded our bootloader in the DL register. I used that "useless" field that we talked about earlier to store its value.

Then I set up the call of the `disk_read` function to read the second sector (LBA 1):

[CODE: Main function calling disk_read]

Now let's compile and run our code. I kept forgetting the command line for running the VM, so I decided to create a `run.sh` shell script which simply contains the QEMU command.

[CODE: run.sh script]

And it looks like we have a problem—the "Hello World" message doesn't appear anymore, so there is a bug somewhere.

## Debugging with Bochs

I think now would be a great time to introduce another extremely useful tool, which is called **Bochs**. This is basically an emulator and debugger for an x86 processor, and we can use it to debug our bootloader.

To get it running, we need to create a configuration file:

[CODE: Bochs configuration file]

First, I set it to emulate a computer with 128 megs of RAM. Then I gave it the path to the ROM and VGA ROM images. Then I configured the floppy drive to contain our disk image with the status "inserted".

Right now we don't need any mouse support, so I disabled it. I set the display library to SDL with the option of the GUI debugger. Bochs also has a command-line debugger, but I prefer the GUI.

To run Bochs, I created another shell script, `debug.sh`, which calls Bochs with the configuration file we just created.

### Installing Bochs

When I tried to run Bochs, I encountered some issues. First of all, it wasn't installed on my machine. In addition to the `bochs` package, I also needed to install:
- `bochs-sdl` for the UI
- `bochsbios` and `vgabios` which contain the ROMs

After that, I encountered another error that the display library SDL wasn't available. The fix for the issue was to set the display library to `sdl2` instead of `sdl`.

[CODE: Updated Bochs config with sdl2]

And now we see the Bochs interface. It's not very pretty, but we can work with it, and it's going to help us a lot.

### Debugging Session

Okay, so let's get everything ready. I'm going to have the code here somewhere so we can see it, like this, and the display window, and now the debugging window.

Okay, so now Bochs has started and it has set a breakpoint right at the beginning of the BIOS. What we're going to do is go to **View → Disassemble**, and in this window we are going to put `7C00`.

[IMAGE: Bochs disassembly window]

`0x7C00` is the address where our bootloader will be loaded, so we are going to double-click it. This will create a breakpoint, and Bochs will stop when it gets here.

So now let's continue.

Okay, so this doesn't look valid to me. So let's go ahead and disassemble again. And now this is correct! So this would be the `jmp short start` instruction.

Now step. So what happened here? The current instruction highlight has disappeared. Well, that's not something to worry about, because we have to go back to **View → Disassemble**, and the new address is also the same one as in the IP register. And let's go there.

Okay, so now we have reached this jump instruction. Let's scroll down and see what happens after this jump of ours. So we should be at the `start` label and at the `jmp main` instruction.

So let's go one more step, and now we are in the `main` label. Okay, let's scroll down to the main label, and now we can recognize the code. So let's go step by step and see what is happening.

First, we just set up a few registers, and we write this into the memory. And then we are calling the `disk_read` method. The parameters look okay.

Now here you can see all the registers. We don't have the AX and BX registers, but we have EAX, EBX, and ECX. This is nothing to worry about because in modern processors, these registers are actually extended and now they're 32-bit, not 16-bit. In order to just see the value of the AX register, for example, we just need to look at the last four digits over here.

Okay, so let's move on. Now we have reached this call to the `disk_read` method, so let's step, and we can go to the `disk_read` method right now.

First, we have pushed a few things to the stack, so let's skip over those. And now we are calling this `lba_to_chs` method, so let's step into it and see what happens.

Okay, so first we pushed some stuff to the stack. We can also see the stack by going to **View → Linear Memory Dump**, and we have to add here the address. In our case, the top of the stack is `0x7BEC`, so we can do that: `0x7BEC`, and press OK. And now we see the value of the stack.

So now this is the logic that performs the LBA to CHS conversion. First, we set the DX register to zero, and then we want to divide the LBA address by the number of sectors per track.

In our case, AX is 1, so 1 divided by the sectors per track (which is 18) will give us the result 0 and the remainder will be 1. So that is the case here—you can see DX is 1, AX is 0.

Okay, now we are increasing DX to calculate the sector, and now we have the sector, which is 2. And we move it to CX. We don't care about these first four digits, just the last four, so we have 2 set to CX.

Okay, now we have the second division. The values are zero, so we can see that DX and AX are zero. And we have the logic that puts everything into the right registers, and we can see the CX register is just 2, DH is zero, and the cylinder is zero.

Now we are popping the registers that we have pushed, so we are restoring DL to its previous value. Okay, so DL is now zero, and we are returning back to where we came from.

So now we are going back to the `disk_read` method, and we have reached this `pop ax`.

Now let's go on. So now we are preparing to call the 13h interrupt, so let's see what happens there. Okay, so we have all the parameters ready. If we look into the documentation, all the parameters should match.

Now we have this `int 13h` instruction. If I click on step, it will take me into the BIOS where the int 13 interrupt is actually handled. We don't really care about that—we just want to see the result. So what I'm going to do is set a breakpoint just after this interrupt, and I'm going to press continue.

And now we have reached this place. This was the `jnc .done` (jump if not carry to the done label), and it looks like it jumps, so it means that the operation succeeded!

And now we have reached this `done` label, and now we are popping all the registers that we have pushed.

### Finding the Bug

And here I found the mistake! So instead of popping DI, DX, and so on, we have **pushed** them.

We can fix that really easily. And let me show you what happens if you mess up the stack. So let's go and skip these instructions. And now we have reached this `ret`.

And if we click on step, now we are at address `0x0201`. What is this? I mean, this is not where we should be!

So what is happening here is that the `ret` instruction expects the return address to be at the top of the stack. But because we pushed instead of popping, the top of the stack contains something else—not the return address. The `ret` instruction is simply interpreting whatever it finds as the return address, which is why we ended up at the address `0x0200` hexadecimal.

So let's fix it and see what happens.

[CODE: Fixing push to pop]

Okay, so now that we have learned what the problem was, we can actually stop Bochs, `make`, and now we can run using the run command we have created.

And we have "Hello World" and then "Read from disk!"

Now I think I know what is happening here—it's not stopping. That's the issue here. Yeah, so we are just calling `hlt` without disabling interrupts. So whenever something happens, like the clock ticks or we move the mouse or we press a key, the processor is interrupted.

If we just `hlt` without disabling interrupts, the processor can still get out of this halt and continue executing, even though we have told it to stop. So that's why we need to disable these interrupts. So that's what we're going to do, and that should solve this issue.

[CODE: cli / hlt loop]

Okay, so let's just `make` and run.

And now we are seeing the "Hello World" message. Unfortunately, we cannot see if the read operation has actually succeeded.

### Verifying the Read Operation

Now let's go back and use Bochs again.

Okay, now we can continue. And we have reached a halt instruction. I'm not really sure why nothing is being displayed here—maybe something is wrong with my configuration.

So let's break now. Go to **View → Linear Memory Dump**. Let's set the address to `0x7E00`, which is where we read the data.

[IMAGE: Bochs memory dump at 0x7E00]

And now let's open the hex editor.

[IMAGE: Hex editor with floppy image]

And I'm going to open the floppy image. And let's go to address `0x200` and see... and this looks like it matches to what we have read! This means that the read is working properly!

**Success!**

## Conclusion

With this, we have reached the end of Part 2. Before you go, let me show you the [Nanobyte GitHub page](https://github.com/nanobyte-dev/nanobyte_os) where you can find all the source code that we have worked on. I will put the link in the description below.

In Part 3, we will talk about the FAT12 file system and how to read files from our disk.

Thank you for watching! If you enjoyed the video, don't forget to like, share, and subscribe.

Bye!
