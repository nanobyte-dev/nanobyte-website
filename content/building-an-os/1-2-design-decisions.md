---
title: "Part 1-2: Design decisions"
weight: 2
---

## Introduction

Building an operating system requires making many design decisions. Some of these are easy to change later, while others become deeply embedded in the architecture. You need to understand the trade-offs.

The choices we make in this tutorial are **our choices for this specific project**. They're not universal truths. Different projects have different goals and constraints. What makes sense here might not make sense for you.

The most important lesson: **choose your battles**. An operating system is incredibly complex. You can't do everything perfectly or support every possible feature. Pick your scope and stick to it. Decide which parts you'll implement yourself, and where you'll use existing software or skip features. Hardware is messy and you can't support it all. Trying to do so will leave you with an unfinished project.

Whether you're working solo or with a small team, you can only do so much. A small, working OS with a few features done well beats an ambitious design that never gets finished.

This section covers the major design decisions we need to make before writing code.

## Target Architectures

Choosing which CPU architectures to support is one of the first and most important decisions. Each architecture has its own quirks, tooling ecosystem, and available hardware for testing.

### Considerations for architecture choice

When choosing architectures, consider:
- **Available hardware** - Do you have physical devices to test on, or will you rely on emulation?
- **Documentation quality** - Are there good, accessible specifications and resources?
- **Complexity and legacy baggage** - How much historical cruft does the architecture carry?
- **Learning value** - Will this architecture teach you useful concepts?
- **Community and tooling** - Is there good compiler support and community help available?
- **Hardware discovery model** - How does the platform handle detecting and configuring hardware?

### Our architecture choices

**[x86-64](https://en.wikipedia.org/wiki/X86)**: Despite its significant legacy baggage, x86 will be our primary architecture. The main reason is practical: most of the hardware available for testing is x86-based. x86 also has excellent documentation, mature tooling, and a large community. The downside is dealing with decades of backwards compatibility quirks, from starting in [16-bit real mode](https://osdev.wiki/wiki/Real_Mode) to managing the complex [APIC](https://osdev.wiki/wiki/APIC) interrupt controller. The architecture has evolved significantly since its introduction in 2003, with new instruction sets and features added in each CPU generation (SSE3, SSE4, AVX, AVX2, AVX-512, etc.). These are grouped into [microarchitecture levels](https://en.wikipedia.org/wiki/X86-64#Microarchitecture_levels) (v1, v2, v3, v4) to define minimum feature sets. Rust requires minimum x86-64-v1 (the baseline with SSE/SSE2), which means we can support all x86-64 CPUs—any CPU newer than an AMD Athlon 64 (2003) or Intel Pentium 4 with EM64T (2004).

**[RISC-V](https://osdev.wiki/wiki/RISC-V)**: For our second architecture, we'll use RISC-V. It offers a cleaner, more modern design without the legacy baggage of older architectures. The specification is truly open, well-documented, and forward-looking. While physical RISC-V hardware is less common than ARM, emulation support is excellent, allowing us to develop and test effectively. If the project proves successful, investing in a RISC-V development board for real hardware testing becomes an option later.

### Alternative architectures

**[ARM/AArch64](https://osdev.wiki/wiki/ARM_Overview)**: ARM is widespread in real hardware (phones, tablets, Raspberry Pi) with a mature ecosystem and extensive documentation. However, it has a significant limitation with hardware discovery—only very few devices support standardized hardware discovery through [UEFI](https://osdev.wiki/wiki/UEFI). For most ARM systems, you need to know the hardware configuration at compile time through [device tree](https://en.wikipedia.org/wiki/Devicetree) files. ARM also carries its own legacy baggage despite being "newer" than x86.

**Older and less common architectures**: There are many other architectures out there—PowerPC, MIPS, SPARC, Alpha, Itanium, and others—but these are either legacy platforms or in decline. While interesting from a historical perspective, they're not practical choices for a modern OS tutorial. We won't be supporting them.

### Single-platform vs. multi-platform codebase

Supporting multiple architectures means writing more code and dealing with abstraction layers. Why do it?

**Multi-platform approach** (our choice):
- Forces you to write cleaner, more modular code from the start
- Teaches you how different architectures solve similar problems differently
- Makes architecture-specific quirks more obvious by contrast
- Gives you cross-platform development experience

**Single-platform approach** (alternative):
- Simpler to develop and debug initially
- Can optimize specifically for one architecture
- Faster progress in early stages
- Valid choice if your goal is to deeply understand one specific architecture

For this tutorial, we'll take the multi-platform approach. The contrast between x86's legacy complexity and RISC-V's modern simplicity will teach us a lot about operating system design.

## Programming Languages

Choosing a programming language for OS development involves very different considerations than typical application development. You could write an OS in JavaScript if you really wanted to, but there are good reasons why nobody does.

### Requirements for OS development languages

When choosing a language for operating system development, consider:

**Hardware access**: How easily can you interact with hardware? Can you read/write specific memory addresses? Can you use inline assembly? Can you define precise memory layouts for hardware structures?

**Performance**: Operating systems run constantly and manage all system resources. Poor performance in the OS affects every program running on the system. Languages with runtime overhead (garbage collection pauses, JIT compilation delays) can be problematic.

**Type system and precision**: When defining APIs for other programs to use, you need precise control over data types. Is this a 16-bit integer or a 64-bit integer? How big is a pointer on this architecture? Languages with vague or platform-dependent types make this difficult. You need explicit, predictable types for hardware registers, memory addresses, and inter-process communication.

**Runtime requirements**: This is important. Every language comes with a runtime (the support code needed to make the language work).

**Control and predictability**: Can you control exactly what machine code gets generated? Are there hidden costs (allocations, function calls) that happen behind your back?

### Available options

#### Most common choices

**[Assembly](https://osdev.wiki/wiki/Assembly)**: The ultimate in hardware control, but extremely tedious and architecture-specific. Assembly gives you complete control over the generated code with no runtime overhead, making it essential for early bootstrapping and architecture-specific operations like setting up paging or switching CPU modes. However, code doesn't port between architectures, there are no abstractions to help manage complexity, and it's easy to make subtle mistakes. We'll need some assembly for architecture-specific bootstrapping, but writing everything in assembly is not practical for a complete OS.

**[C](https://osdev.wiki/wiki/C)**: The traditional choice for OS development, and still the most common. C has a tiny runtime that's already mostly OS-independent (for GCC this is libgcc, for LLVM/Clang it's compiler-rt). These libraries provide low-level support routines that the compiler needs: arithmetic operations not supported by the target hardware (like 64-bit division on 32-bit platforms, soft-float operations, bit manipulation functions), stack unwinding for exception handling, and other compiler built-ins. This minimal runtime is easy to work with and OS-agnostic. C offers excellent hardware access through pointers and inline assembly, good performance, mature tooling, and decades of accumulated OS development knowledge. The entire Linux kernel, most Unix systems, and tons of embedded systems are written in C. However, C provides no memory safety—it's easy to introduce buffer overflows, use-after-free bugs, and other vulnerabilities. Manual memory management and lack of modern abstractions mean more bugs make it to production.

**[C++](https://osdev.wiki/wiki/C%2B%2B)**: Adds useful abstractions (classes, templates, RAII for resource management) while maintaining C's performance and hardware access. Most C++ features have zero runtime cost, and you can disable expensive features like [RTTI](https://osdev.wiki/wiki/Libsupcxx) (Run-Time Type Information) and exceptions that require runtime support. C++ is used in Windows (alongside C), macOS XNU kernel's IOKit driver framework, and Google's Fuchsia OS. The downsides are a larger and more complex runtime than C (though still manageable), a very complex language with many ways to shoot yourself in the foot, longer compile times, and the potential to write inefficient code if you're not careful about which features you use.

**[Rust](https://osdev.wiki/wiki/Rust)**: Offers memory safety guarantees through its ownership and borrowing system, preventing entire classes of bugs (use-after-free, double-free, data races) at compile time without requiring garbage collection. For OS development, Rust uses `#![no_std]` mode, which links to the minimal `core` library instead of the full standard library. The `core` library is platform-agnostic and makes no assumptions about the system. Runtime requirements are minimal—primarily you need to implement a `panic_handler`, and you can optionally include the `alloc` crate for heap allocation support. Rust has an active and growing OS development community with projects like [Redox OS](http://www.redox-os.org/) and [Tock OS](https://www.tockos.org/), and is being adopted for Linux kernel drivers and Android OS components. The main challenges are a steep learning curve, the borrow checker can be restrictive when writing low-level code (sometimes requiring `unsafe` blocks), and compile times can be long.

#### Experimental options

These languages are viable for OS development but have smaller communities and less mature ecosystems.

**[Zig](https://osdev.wiki/wiki/Zig_Bare_Bones)**: A newer language explicitly designed with systems programming in mind. Zig enforces no hidden allocations and no hidden control flow—everything is explicit, giving you complete control. It has excellent C interoperability (can call C functions directly and include C headers without bindings), built-in cross-compilation support in the build system, and compile-time metaprogramming instead of macros. The standard library performs no allocations internally, giving complete control over memory usage. Zig is cleaner and simpler than C++ while still providing the control needed for OS development. However, the language is still evolving (not at 1.0 yet), the community is smaller, there are fewer learning resources, and tooling is less mature than established languages.

**[D](https://osdev.wiki/wiki/D)**: A high-level language that retains the ability to interface directly with hardware and operating system APIs. D has been successfully used for kernel development in projects like [PowerNex](https://github.com/PowerNex/PowerNex) and [XOmB](https://github.com/xomboverlord/xomb). Using LDC (the LLVM D compiler) enables targeting many architectures including ARM, RISC-V, x86, and more. For kernel development, you use a minimal D runtime (similar to Rust's approach), avoiding the full standard library. D offers modern language features while maintaining low-level control, but has a smaller community than mainstream options and less OS development documentation available.

**Nim**: A statically typed compiled systems programming language with deterministic memory management using destructors and move semantics (inspired by C++ and Rust). The [nimkernel](https://github.com/dom96/nimkernel) project demonstrates that kernel development in Nim is feasible. Nim compiles to C, which means you can leverage existing C toolchains and cross-compilation infrastructure. It offers a clean, readable syntax while supporting low-level operations. However, the OS development community is small, runtime adaptation is required for bare-metal work, and there are fewer resources and examples compared to mainstream languages. (See also: [OS development tutorial in Nim](https://0xc0ffee.netlify.app/osdev/01-intro))

**[Carbon](https://github.com/carbon-language/carbon-lang)**: Google's experimental successor to C++, designed for systems programming with full C++ interoperability. The language aims to address modern development concerns like memory safety while maintaining performance. However, Carbon is too early-stage to be practical—the MVP version isn't expected until 2026 at the earliest, with a production-ready 1.0 release sometime after 2028. The language's future and adoption remain uncertain.

#### Less well-suited options

**Managed languages** (C#/.NET, Java, Go): These languages offer memory safety and modern features, but require porting an entire runtime environment. For .NET, you'd need to port the CLR; for Java, the JVM. This is a massive undertaking—you're essentially building a complex runtime system before you can even start on OS features. Additionally, garbage collection pauses can be problematic for kernel code that needs predictable timing. Some hobby OS projects do this as a learning exercise ([Singularity OS](https://www.microsoft.com/en-us/research/project/singularity/) in C#, [JNode](https://github.com/jnode/jnode) in Java), but it's impractical for most projects and doesn't teach you much about low-level OS concepts.

**Interpreted languages** (JavaScript, Python, Ruby): These require a full interpreter or virtual machine to run, which means you'd need to implement that entire interpreter in another language first. They also have poor performance characteristics and limited hardware access. While impractical for kernel development, they could potentially be used for userspace utilities and applications once your OS is running and can host an interpreter.

### Our choices

For this tutorial, we'll use **Rust** as our primary language for the kernel and most OS components. This is admittedly a learning exercise. I'm more comfortable with C++, but learning Rust while building an OS should teach me a lot about its memory safety guarantees and modern systems programming approach. The growing Rust OS development community and excellent tooling (cargo, rust-analyzer) will help along the way.

We'll still need **Assembly** for the earliest bootstrapping code on each architecture (the code that runs before we can hand off to Rust). This will be kept minimal, just enough to set up a stack, enter the appropriate CPU mode, and jump to Rust code.

## Hardware Support Philosophy

Hardware support is one of the biggest challenges in OS development. Individual drivers, particularly graphics drivers, can be as complex as entire operating systems and often have poor documentation. We need to choose our battles carefully.

### The impossibility of supporting all hardware

Even Linux, with thousands of developers and decades of work, struggles to support every piece of hardware. A single developer or small team has no hope of supporting everything. You need to pick what to support and what to ignore.

### Legacy vs. modern hardware trade-offs

When IBM introduced the PC in 1981 and the PC/AT in 1984, their hardware choices became de facto standards that persisted for decades through widespread cloning and backwards compatibility requirements. Modern PCs have evolved far beyond these IBM-era baselines. We've traded the simplicity of universal legacy interfaces for the complexity (and capabilities) of modern computing.

Legacy and modern hardware represent different trade-offs:

**Legacy hardware** ([PIC](https://osdev.wiki/wiki/8259_PIC) interrupt controller, [PS/2](https://osdev.wiki/wiki/Ps2) keyboards, [VGA](https://osdev.wiki/wiki/VGA_Resources) text mode, [Sound Blaster 16](https://osdev.wiki/wiki/Sound_Blaster_16), [NE2000](https://osdev.wiki/wiki/Ne2000) network cards) is simpler to program and well-documented. Modern systems still support some of these legacy interfaces in different ways:

- **[PIC (Programmable Interrupt Controller)](https://osdev.wiki/wiki/8259_PIC)**: While [APIC](https://osdev.wiki/wiki/APIC) is the modern standard, the legacy 8259 PIC interface is still provided by the Platform Controller Hub (southbridge) on modern motherboards, integrated into the chipset. Both interrupt controllers coexist on modern x86 systems.

- **USB legacy support**: BIOS/UEFI firmware provides [USB keyboard and mouse emulation as PS/2 devices](https://www.kernel.org/doc/html/next/x86/usb-legacy-support.html) through System Management Mode (SMM), allowing USB devices to work in BIOS setup, bootloaders, and DOS environments.

- **Graphics VGA compatibility**: [Legacy VGA support varies by generation](https://forums.tomshardware.com/threads/nvidia-chipset-graphics-cards-that-will-work-with-legacy-bios.3732049/). Nvidia 700 series and AMD R9 300 series were the last with native VGA hardware. Modern cards:
  - Nvidia GTX 10-series: Generally support legacy BIOS/CSM
  - Nvidia RTX 20/30-series: Mostly UEFI-only, unreliable legacy support
  - AMD RX 400/500 series: Often work with legacy (varies by manufacturer)
  - AMD RX 5000-7000 series: Hybrid ROM but unreliable legacy support
  - [AMD RX 9000 series and newer](https://www.amd.com/en/resources/support-articles/faqs/GPU-N4XCSM.html): Officially UEFI-only, no CSM support

- **[CSM (Compatibility Support Module)](https://en.wikipedia.org/wiki/UEFI#CSM_booting)**: UEFI firmware's CSM provides legacy BIOS boot services, but newer motherboards are increasingly dropping CSM support entirely.

Despite declining hardware support, legacy interfaces remain widely available in emulation environments (QEMU, VirtualBox) and on older physical hardware that's readily available and inexpensive.

**Modern hardware** ([APIC](https://osdev.wiki/wiki/APIC)/x2APIC, [USB](https://osdev.wiki/wiki/Universal_Serial_Bus), PCIe graphics, HD Audio, modern network controllers, [ACPI](https://osdev.wiki/wiki/ACPI)) is what runs on current machines but involves significant complexity:

- **Audio**: [Intel HD Audio replaced AC97 in 2004](https://en.wikipedia.org/wiki/Intel_High_Definition_Audio) with NO backward compatibility. Modern motherboards are HD Audio only; AC97 exists only in emulation or truly legacy hardware.

- **Networking**: Modern physical NICs have no legacy compatibility modes. [RTL8139](https://osdev.wiki/wiki/RTL8139), [e1000](https://osdev.wiki/wiki/Intel_Ethernet_i217), and [NE2000](https://osdev.wiki/wiki/Ne2000) are only available as [emulated devices in virtualization](https://wiki.qemu.org/Documentation/Networking), not on physical modern hardware.

- **USB**: Multiple controller standards ([UHCI](https://osdev.wiki/wiki/Universal_Host_Controller_Interface), [OHCI](https://osdev.wiki/wiki/Open_Host_Controller_Interface), [EHCI](https://osdev.wiki/wiki/Enhanced_Host_Controller_Interface), [xHCI](https://osdev.wiki/wiki/XHCI)) with complex protocols make USB a massive undertaking.

- **[ACPI](https://osdev.wiki/wiki/ACPI) (Advanced Configuration and Power Interface)**: Modern systems use ACPI for hardware enumeration, power management, and configuration. ACPI tables contain AML (ACPI Machine Language) bytecode that requires implementing an interpreter in your OS. This is a massive, complex specification compared to simple hardware probing.

We'll start with emulated legacy/simple hardware in QEMU to get a working system, then add modern hardware support incrementally if needed.

### Choosing specific target platforms

Instead of trying to support all hardware, we'll target specific platforms:

**Primary target: QEMU virtual machines**

QEMU provides consistent, well-documented virtual hardware:

- **Graphics**: [VESA/VBE](https://osdev.wiki/wiki/VESA_Video_Modes) (BIOS) and [GOP](https://osdev.wiki/wiki/GOP) (Graphics Output Protocol - UEFI) for framebuffer access. We may fall back to basic [VGA text mode](https://osdev.wiki/wiki/VGA_Resources) (80x25) for early debugging, but will target framebuffer graphics as the primary interface.
- **Networking**: [RTL8139](https://osdev.wiki/wiki/RTL8139) or [e1000](https://osdev.wiki/wiki/Intel_Ethernet_i217) (both simple, well-documented, widely emulated)
- **Storage**: [IDE/ATA](https://osdev.wiki/wiki/ATA_read/write_sectors) (simpler than modern [AHCI](https://osdev.wiki/wiki/AHCI)/[NVMe](https://osdev.wiki/wiki/NVMe))
- **Serial**: [16550A UART](https://osdev.wiki/wiki/UART) for debugging output
- **For x86**: Standard PC hardware emulation
- **For RISC-V**: The 'virt' board with [VirtIO](https://osdev.wiki/wiki/Virtio) devices, CLINT, PLIC

**Secondary target: Specific physical hardware**

Once working in QEMU, test on specific real hardware (an older laptop with legacy BIOS or a UEFI-capable machine). This will reveal issues that emulation hides and force us to handle real-world hardware quirks. We'll support exactly one or two physical machine models, not attempt broad compatibility.

### Migration path and scope limitations

The strategy:
1. **Start with QEMU** - Get everything working in a controlled environment
2. **Add support for specific physical hardware** - One laptop/board model you own
3. **Expand cautiously** - Only add support for additional hardware if there's a compelling reason

We explicitly will NOT attempt to support (initially):
- **USB** - Too complex for early development
- **Modern graphics drivers** - Start with framebuffer (VESA/GOP); modern GPU drivers are enormous undertakings
- **Audio** - Not critical for a functioning OS (note: [Sound Blaster 16](https://osdev.wiki/wiki/Sound_Blaster_16) has [broken QEMU support in recent versions](https://forum.osdev.org/viewtopic.php?t=39652); AC97 is emulated but modern hardware lacks compatibility)
- **Complex storage controllers** - Stick with IDE/AHCI basics
- **Broad hardware compatibility** - Support specific devices, not device classes

## Project Scope

Writing an operating system from scratch is a huge endeavor that takes an enormous amount of time. We need to be smart about where we spend that time.

Let's keep our goals in mind: we want to explore kernel design, try some novel ideas, and not be constrained by just copying existing designs. But that doesn't mean we need to write everything from scratch. Let's not reinvent the horse and carriage—reinventing the wheel is enough. We could implement every single component ourselves, but that would take forever and we'd never finish.

Instead, we'll spend our time on the interesting OS-specific stuff and use libraries for the tedious parts. Writing a JSON parser teaches you nothing about operating systems. Implementing virtual memory? That's the good stuff.

Here's how I decided to prioritize what we're going to do:

### Core features (highest priority)

The foundation that everything else builds on: memory management, process management, basic I/O, filesystem, and a way to run userspace programs. Without these, you don't have a functioning OS.

### Mid priority

Once the core works: GUI (because it's more fun than fancy CLI features), multicore support, users and permissions, debugging tools.

### Lower priority

These can come later: networking, USB support, sound.

### Out of scope

Some things we explicitly won't attempt:

- **3D/accelerated graphics**: Modern GPU drivers are enormous (hundreds of thousands of lines of code). We'll stick with framebuffer graphics. If you want accelerated graphics, that's a whole separate project.

- **Complete hardware support**: As discussed in the Hardware Support Philosophy section, we're targeting specific platforms, not every piece of hardware ever made.

### What we'll implement ourselves vs. use existing code

**Building from scratch:**
- Bootloader (for both x86 and RISC-V)
- Kernel (all core OS functionality, including minimal kernel runtime support)

**Using existing implementations:**
- **ACPI parser**: We'll port an existing ACPI implementation (like ACPICA, which Linux also uses). ACPI is a massive specification with an entire bytecode interpreter. No point reimplementing this.
- **Userspace standard libraries**: We'll port existing libc for userspace programs. For C++ applications, we'll use existing STL implementations. In the kernel, we'll only implement what we absolutely need (no full libc in kernel space).
- **Parsers**: XML, JSON, and other data format parsers. Parsing is tedious and error-prone. We'll use battle-tested libraries.
- **Browser engines**: If we want a web browser, we'll port an existing engine. Writing a browser engine is a multi-year project by itself.
- **Advanced math**: Linear algebra libraries, cryptography implementations, etc. Use well-tested code for this.

The goal is to learn about operating systems, not to rewrite every wheel. We'll focus our effort on the OS-specific parts and leverage existing work for everything else.

## Unix-like or not?

I decided not to build a Unix-like OS. No POSIX compliance, no trying to be compatible with Linux or BSD.

Why? Unix-like systems are everywhere. Linux, the BSDs, macOS—they're all variations on the same theme. Most OS development tutorials and hobby operating systems follow this path too. It's well-trodden ground.

I want to do something different. I want to explore alternative design decisions and try new things. What if processes communicate differently? What if the filesystem works in a new way? What if we rethink how drivers interact with the kernel? These are interesting questions, and I can't explore them if I'm constrained by POSIX compatibility.

I'll still steal good ideas from Unix where they make sense. But I won't be a slave to compatibility. The goal is to learn, experiment, and create something unique—not to build Yet Another Unix Clone.

## Development Approach

We've already covered what we'll build ourselves versus what we'll use from existing implementations in the Project Scope section.

One important thing: **automated testing from the start**. We'll write tests as we build features. Unit tests for kernel components, integration tests for system behavior. A test suite will save us a lot of time debugging weird issues. It's easier to start with good testing practices than to retrofit them later.
