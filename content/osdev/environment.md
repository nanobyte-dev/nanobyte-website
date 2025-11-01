---
title: "Setting up an OS development environment"
---

You want to start working on your own operating system, but don't know where to start? This article describes the tools and settings you need to configure to prepare your system for operating system development.

A long time ago, writing an operating system was done by writing assembly code _on paper_, going through the CPU manual and translating every assembly instruction into binary by hand, and then punching tape using a special typewriter (citation needed). Luckily for us, things have gotten a lot better and we have much better tools available. We have smart editors to help us write code easier, advanced compilers and assemblers, and really good debugging tools.

## The host operating system

While there are development tools available for pretty much any general purpose OS, not all existing OSs are well suited for creating your own operating system; some are too restrictive, and the available tools leave a lot to be desired.

For the best experience, the general recommendation is to use a Unix-like system such as Linux, MacOS or a BSD variant.

### Windows

Windows is the most popular operating system for the desktop. There are multiple ways of setting it up for OS development:

- using WSL to create a Linux environment. Most OS developers choose this path, and is the one used in the tutorials on this site
- using a port of the Linux tools, such as Cygwin or MSYS2. The main disadvantages are the performance of the tools (e.g. the compiler) which means longer compile times, and the difficulty of creating disk images on Windows
- using native Windows and Microsoft tools (article coming soon)

#### Setting up WSL

WSL is really easy to set up. All you have to do is open an elevated command prompt (i.e. run as administrator), and run:

```batch
wsl --install
```

This will install all the prerequisites and will set up an Ubuntu distribution. After installation, you only need to search for "Ubuntu" in the start menu to open the WSL instance. Many tools, such as Visual Studio Code and Windows Terminal, will automatically detect any installed distribution and make it very easy to interact with.

For more information, as well as instructions on how to install different distributions, [check the official documentation](https://learn.microsoft.com/en-us/windows/wsl/install).

Caveat: There are 2 versions of WSL. WSL 1 is built as a translation layer that translate linux system calls into Windows system calls. This has some limitations, the most notable is the lack of support for mounting devices. There are other limitations too that you will encounter when running certain Linux programs. WSL 2 works by virtualizing the Linux kernel and providing a "transparency" layer that has features like the integrated file system, a built-in X server for running GUI applications and audio pass-through. If you encounter problems running certain commands, you might be using WSL 1, in which case you will have to migrate your distribution to WSL 2.

### Linux

If you are using Linux, you are already set up, all you need is to install the tools in the chapters below.

### MacOS

While MacOS is a Unix-like operating system, it doesn't come with all tools out of the box, so you will need to install [homebrew](https://brew.sh/).

There are some small differences between Linux and MacOS, such as the commands used to set up loopback devices, or the commands used to format a disk. It is a lot more similar to FreeBSD than Linux.

### Others

- **BSD**: you are already set up, you just need to install the tools below.
- **Android**: even though Android runs Linux under the hood, it is heavily locked down, making it a very poor choice for OS development. While most required tools can be found in [Termux](https://termux.dev/en/), there are many limitations such as not being able to mount disk images unless the device is rooted. Another issue is that most Android devices are built on the ARM architecture. If you're working on an x86 operating system, you will need to emulate x86 which will be very slow.
- **ChromeOS**: similar issues to Android. The best option is to create a virtual machine running a Linux distribution, and doing the development in that virtual machine.
- **iOS**: the operating system is too locked down to allow any kind of software development on the device. Even worse, Apple doesn't allow most emulators in the App Store, which means you have to sideload and/or jailbreak your device in order to use one.
- **MS-DOS, FreeDOS**: there are plenty of compilers and tools available (such as DjGPP, Turbo C, Microsoft C, Watcom etc). The main limitations are the fact that pretty much all the tools are outdated and unmaintained, the memory limits of MS-DOS (later software used DOS extenders which alleviated the issue), the lack of proper source control, and the lack of debugging tools. You also cannot virtualize, so you likely have to test on real hardware. Can be a fun exercise if you enjoy retro computing.

## The toolchain

As part of your toolchain, you will need an assembler, a compiler, a linker and a tool to automate your build process.

### The assembler

An assembler is a tool that translates human readable assembly code into machine code that the processor can execute. The main difference from a compiler is that assemblers are purposefully built to have a 1:1 mapping between the human readable instructions and the machine code.

Most people use either [GAS](https://wiki.osdev.org/GAS) (which comes with the binutils package) or [NASM](https://www.nasm.us/). For a native windows development environment, [MASM](https://wiki.osdev.org/MASM) is the best choice.

### The compiler

Compiler choice will depend on the programming language you decide to use for your project. The important part is that [you use a cross compiler](https://wiki.osdev.org/Why_do_I_need_a_Cross_Compiler%3F) that is capable of emitting freestanding binaries that don't depend on features of existing operating systems.

Traditionally, C and C++ have been the most commonly used languages. [GCC](https://wiki.osdev.org/GCC_Cross-Compiler) and [Clang](https://wiki.osdev.org/LLVM_Cross-Compiler) are the most commonly used C/C++ compilers. On a native windows development environment, your main choice is the [Microsoft Visual C++ compiler](https://wiki.osdev.org/Visual_Studio).

Lately, there has been an increasing number of people using [Rust](https://wiki.osdev.org/Rust).

### The linker

In most cases, you would use the linker that comes with your compiler. It's important that you familiarize yourself with how it works, and how you can configure it for OS development. (more info needed)

### Build automation

In the beginning, you may have a single assembly file that you can compile by hand, by typing the assembler command. However, as your project grows, you will find it tedious to write every command by hand, so you will want to automate the process.

The simplest form of build automation is to use a shell/batch script. But once the project grows to a few dozen files, the compile times will start to grow.

This is where build automation tools like [make](https://makefiletutorial.com/) can help. Unlike a shell script, a Makefile also defines the dependencies between input, intermediate and output files. For example, you can specify that the output file Z depends on the object file Y, and the object file Y depends on the source file X. Make can look at all these dependencies and trigger a compilation of only the files that have changed. Additionally, make can figure out what things it can do in parallel and take advantage of multiple CPU cores. These improvements save a lot of time.

## The editor

Any text editor can be used to write the operating system, and the choice comes down to preference. Some people really love the old-school Linux terminal-based editors like vim and emacs. Others prefer something more modern, like Visual Studio Code, or a fully fledged IDE like Clion, RustRover, Eclipse, Visual Studio etc. The choice is up to you.

## Debuggers and virtualization software

For testing your operating system, it is ideal to use virtualization. This way, you save a lot of time, since starting a virtual machine is much faster than copying your OS to a physical media, putting it in another PC (or even worse, restarting your main PC). Also, most virtualization tools offer built-in debugging capabilities, or integrations with existing debuggers which is very helpful.

- Bochs is an x86 emulator and debugger
- Qemu - offers a GDB interface that can be used for debugging
- VirtualBox - has limited [debugging functionality](https://www.virtualbox.org/manual/ch12.html#ts_debugger). It can also [integrate with GDB](http://sysprogs.com/VBoxGDB/tutorial/).
- VMWare - can [integrate with GDB](https://wiki.osdev.org/VMware)
