---
title: "Part 2: The x86 boot process"
---

The x86 platform has evolved a lot over the years. One of the most important aspects of x86 is backwards compatibility, a modern x86 system must be able to run software that was written 5, or 10, or 20 years ago without a hitch. As a consequence, changes have often been done in a way that _adds_ functionality without removing or altering any prior functionality. In other words, x86 is messy, filled with deprecated ideas and technologies. The boot process is no exception.

![Intel 8086 CPU](/images/Intel_C8086.jpg)

The Intel 8086, released in 1978, is the first CPU having the x86 architecture.

The process typically begins with the BIOS, or to be pedantic, the motherboard firmware, which is the first code that gets executed when a computer powers on. The firmware's purpose is to bring the system into a working state, do some short checks that all the hardware is working properly, and then start an operating system. It also provides some basic IO, which consists of some rudimentary drivers for some of the hardware, so that the operating system can get itself started (this is where the BIOS abbreviation comes from, "_Basic Input-Output System_").

There are 2 major ways in which the motherboard firmware can load an operating system: _legacy_ and _UEFI_. While _UEFI_ is more modern, and hardware manufacturers have started phasing out _legacy_ booting, I decided to use the _legacy_ method for this tutorial. My main reasoning is that _legacy_ booting is still widely supported in virtualization software, which we will use a lot, and it will also allow people to use an older computer that they might have around for testing their operating system.

## Legacy boot process

In _legacy booting mode_, the BIOS goes through each device configured in the boot order, and attempts to load the first sector into memory at address 0x7C00. Then, it checks if that sector has a specific signature; more exactly, it checks that the last 2 bytes are 0x55 and 0xAA. If it finds that signature, it starts executing from address 0x7C00; otherwise, it moves on to the next device in the boot order, and repeats the process.

So what do we need to do so that the BIOS will load and execute our own code? We need to write a small program that is exactly 1 sector long, make sure it has that particular signature, and then place it as the first sector of a disk.

## How do we write such a program?

Unfortunately, sectors are **really small**. More exactly, 512 bytes small. If you write a "Hello world" program in C, and compile it on any operating system, using any compiler, it will be larger than 512 bytes. I actually tried it on a modern Linux machine using GCC, and the output binary was 16kb in size.

![C Hello World Binary Size](/images/c-hello-world-size.png)

Of course, there are good reasons why this happens; the compiler inserts some bootstrapping and cleanup code into the output binary. Also, the output file contains headers telling the operating system how it should be loaded, what libraries it depends on, and other pieces of information. But even if we removed all that, and used the best optimization settings, it would be pretty difficult to fit in 512 bytes.

Even worse, because of backwards compatibility, the processor has to start in a really weird operating mode called _16-bit real mode_. This mode has been obsolete for decades, which is why modern compilers don't bother supporting it anymore. If we really wanted to use C, our options would be to either use an obscure, lesser known, perhaps buggy compiler (like OpenWatcom, Digital Mars, SmallerC etc), or use an ancient compiler from the 1980s (Watcom, Turbo C, etc) which comes with its own set of problems, starting with the fact that they aren't compatible with modern operating systems.

Fortunately, there is still a way to write this program using modern tools, by writing it in _x86 Assembly_.
