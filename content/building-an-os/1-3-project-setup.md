---
title: "Part 1-3: Project Setup"
weight: 3
---

## Introduction

Before we can write any actual OS code, we need to set up the project structure, build system, and configuration files. This might seem tedious, but having a good structure from the start will save a lot of headaches later.

In this part, we'll set up:
- Project directory structure
- Build system for multiple bootloaders and platforms
- Linker scripts for different boot targets
- Basic bootloader scaffolding
- A minimal "hello world" that displays text on screen

Our goal is to get something working on all our target platforms: x86-64 (both BIOS/CSM and UEFI) and RISC-V (UEFI).

## Project Structure

We need to organize our code to support multiple bootloaders (BIOS and UEFI) and multiple architectures (x86-64 and RISC-V).

### Directory Layout

```
project-root/
├── bootloader/
│   ├── bios-x86_64/          # BIOS/CSM bootloader for x86-64 (C)
│   │   ├── stage1/           # 512-byte boot sector (assembly)
│   │   ├── stage2/           # Main bootloader (C + assembly)
│   │   └── Makefile
│   ├── uefi-x86_64/          # UEFI bootloader for x86-64 (Rust)
│   │   ├── src/
│   │   └── Cargo.toml
│   ├── uefi-riscv64/         # UEFI bootloader for RISC-V (Rust)
│   │   ├── src/
│   │   └── Cargo.toml
│   └── common/               # Shared code (boot protocol definitions)
│       └── boot_protocol.h / boot_protocol.rs
├── kernel/
│   ├── src/
│   │   ├── main.rs
│   │   └── arch/
│   │       ├── x86_64/
│   │       └── riscv64/
│   └── Cargo.toml
└── Makefile                   # Top-level build orchestration
```

### Why This Structure?

{{< wip >}}
Explain the rationale for separating bootloaders by platform and boot method.
{{< /wip >}}

## Setting Up the BIOS Bootloader (x86-64)

The BIOS bootloader is the most complex because it starts in 16-bit real mode and needs to work within severe constraints.

### Stage 1: The Boot Sector

{{< wip >}}
- 512 bytes, ends with 0x55AA signature
- Written in assembly
- Loads stage 2 from disk
- Basic disk I/O using BIOS INT 13h
{{< /wip >}}

### Stage 2: The Main Bootloader

{{< wip >}}
- Written in C (with some assembly helpers)
- Implements filesystem reading
- Parses config file
- Loads and parses kernel ELF
- Sets up memory map
- Switches to protected mode, then long mode
- Jumps to kernel
{{< /wip >}}

### Build System for BIOS Bootloader

{{< wip >}}
- Makefile for building assembly and C code
- Cross-compiler configuration
- Linking everything together
- Creating the bootable image
{{< /wip >}}

### Linker Script

{{< wip >}}
- Explain memory layout
- Boot sector at 0x7C00
- Stage 2 loading address
- Ensuring proper alignment
{{< /wip >}}

## Setting Up the UEFI Bootloaders

UEFI bootloaders are much simpler because UEFI provides services for file I/O, memory management, and graphics.

### UEFI for x86-64

{{< wip >}}
- Using the Rust `uefi` crate
- Cargo.toml configuration
- Target specification: x86_64-unknown-uefi
- Basic UEFI application structure
{{< /wip >}}

### UEFI for RISC-V

{{< wip >}}
- Similar to x86-64 UEFI
- Target specification: riscv64gc-unknown-uefi
- Platform-specific considerations
{{< /wip >}}

### Rust Configuration for UEFI

{{< wip >}}
- Cargo configuration
- no_std environment
- panic handler
- Using UEFI boot services
{{< /wip >}}

## The Boot Protocol

{{< wip >}}
- Introduce the concept
- Common data structure all bootloaders pass to kernel
- For now, just define minimal structure (magic number, basic info)
- Will expand in Part 4
{{< /wip >}}

## Building the Project

{{< wip >}}
- Top-level Makefile
- Building all bootloader variants
- Building the kernel
- Creating bootable images for testing
{{< /wip >}}

## Hello World: Displaying Text

Now that we have the structure, let's get something on screen for each platform.

### BIOS: Text Mode

{{< wip >}}
- Using VGA text mode (80x25)
- Writing directly to video memory at 0xB8000
- Simple "Hello from BIOS!" message
{{< /wip >}}

### UEFI: Graphics Output Protocol

{{< wip >}}
- Using GOP to get a framebuffer
- Drawing text on framebuffer
- Simple "Hello from UEFI!" message
{{< /wip >}}

### Testing in QEMU

{{< wip >}}
- Running the BIOS bootloader
- Running the UEFI bootloader (x86-64)
- Running the RISC-V UEFI bootloader
- Verifying output on all platforms
{{< /wip >}}

## What's Next?

In the next part, we'll dive deeper into the boot protocol and bootloader architecture, understanding what information needs to be passed from bootloader to kernel.
