---
title: "Part 2-1: Boot Protocol & Bootloader Architecture"
weight: 10
---

## Introduction

In the previous part, we set up the basic project structure and got a simple "Hello World" working. Now we need to think about how the bootloader and kernel will communicate.

The bootloader's job is to prepare the system and load the kernel. The kernel needs information about the system to run properly. The **boot protocol** is the contract between bootloader and kernel: a standardized way to pass information.

## Why Do We Need a Boot Protocol?

We're building three different bootloaders:
- BIOS/CSM bootloader (x86-64, written in C)
- UEFI bootloader (x86-64, written in Rust)
- UEFI bootloader (RISC-V, written in Rust)

Our kernel should work regardless of which bootloader started it. The boot protocol ensures that all bootloaders provide the same information in the same format.

### What Information Does the Kernel Need?

The kernel starts with essentially no knowledge about the system. The bootloader must tell it:

**Memory information:**
- Where is usable RAM?
- What regions are reserved for hardware?
- Where did the bootloader load kernel modules?

**Graphics information:**
- Framebuffer location and size
- Pixel format (RGB? BGR? bits per pixel?)
- Screen dimensions

**Hardware information:**
- ACPI tables location (x86-64)
- Device tree location (RISC-V)
- Detected hardware features

**Boot configuration:**
- Command line arguments from config file
- Which modules were loaded (initrd, drivers, etc.)

**System state:**
- What CPU mode are we in?
- Is paging enabled? What's the page table layout?
- What's the memory model?

We won't define all of this upfront. As we implement features in later parts (memory management, graphics, etc.), we'll add the corresponding fields to the boot protocol.

## Target CPU State

Before jumping to the kernel, all bootloaders must bring the CPU to a consistent, well-defined state.

### A Brief Note on Paging

Modern operating systems use **virtual memory** through a mechanism called **paging**. Instead of programs accessing physical RAM addresses directly, they use virtual addresses that the CPU translates to physical addresses using page tables.

For an OS kernel, this means:
- The kernel is compiled to run at high virtual addresses (like 0xFFFFFFFF80000000 on x86-64)
- The bootloader must set up page tables that map these virtual addresses to the actual physical memory where the kernel was loaded
- This is called a "higher-half kernel" design

Why do this? Because it's much easier for the bootloader to set up the mapping than for the kernel to relocate itself after it's already running. The kernel can be linked to its final virtual address and just work.

We'll cover how paging actually works in detail in Part 3-X (Memory Management). For now, just understand that the bootloader needs to set up basic page tables before jumping to the kernel.

### For x86-64

- **CPU in long mode (64-bit)**: The processor must be in 64-bit long mode, not 16-bit real mode or 32-bit protected mode
- **Paging enabled**: Page tables set up with:
  - Identity mapping for lower memory (bootloader and boot info structures)
  - Higher-half kernel mapping (kernel at virtual address 0xFFFFFFFF80000000+)
- **Interrupts disabled**: The kernel will set up its own interrupt handlers
- **Segment registers**: Set up with flat memory model (all segments cover full address space)
- **Stack pointer valid**: Points to a valid, mapped stack region

### For RISC-V

- **CPU in supervisor mode (S-mode)**: Not machine mode (M-mode) or user mode (U-mode)
- **Paging enabled**: Sv39 or Sv48 paging mode with:
  - Identity mapping for lower memory
  - Higher-half kernel mapping
- **Interrupts disabled**: The kernel will configure its own interrupt handling
- **Stack pointer valid**: Points to a valid, mapped stack region
- **Device tree pointer**: Register a0 or a1 contains pointer to device tree blob (DTB)

## Bootloader Architecture Overview

Let's understand the high-level architecture of each bootloader variant and why they're different.

### BIOS/CSM Bootloader (x86-64)

This is the most complex bootloader because of x86's legacy.

**Constraints and challenges:**
- Starts in 16-bit real mode
- Initial code must fit in 512 bytes
- Must use BIOS interrupts for disk I/O
- Needs multiple mode switches: real → protected → long mode

**Multi-stage architecture:**

{{< wip >}}
**Stage 1 (Boot sector - Assembly)**
- 512 bytes loaded at 0x7C00 by BIOS
- Loads stage 2 from disk using BIOS INT 13h
- Minimal: just enough to load next stage

**Stage 2 (Main bootloader - C + Assembly)**
- Implements filesystem driver
- Reads and parses config file
- Loads kernel ELF and modules into memory
- Parses kernel ELF headers
- Collects system information (memory map, etc.)
- Sets up paging structures
- Switches to protected mode (for C code)
- Can switch back to real mode for BIOS calls when needed
- Finally switches to long mode
- Jumps to kernel entry point
{{< /wip >}}

### UEFI Bootloader (x86-64)

Much simpler because UEFI provides services and starts in long mode.

{{< wip >}}
**Single-stage architecture:**
- UEFI loads us directly as a PE32+ executable
- Already in long mode
- Use UEFI boot services for:
  - File I/O (read config, kernel, modules)
  - Memory map
  - Graphics (GOP - Graphics Output Protocol)
- Parse kernel ELF
- Set up paging structures
- Exit UEFI boot services
- Jump to kernel
{{< /wip >}}

### UEFI Bootloader (RISC-V)

Similar to x86-64 UEFI but with platform differences.

{{< wip >}}
**Single-stage architecture:**
- UEFI loads us as a PE32+ executable
- Already in supervisor mode
- UEFI provides similar services
- Key difference: device tree instead of ACPI
- Set up RISC-V paging (Sv39/Sv48)
- Exit boot services
- Jump to kernel
{{< /wip >}}

## The Boot Protocol Structure

The boot protocol is a data structure that the bootloader prepares and passes to the kernel. The kernel receives a pointer to this structure.

### Initial Structure

For now, we'll define a minimal structure. We'll expand it in later parts as we implement more features.

{{< wip >}}
```c
// C version (for BIOS bootloader)
struct boot_info {
    uint32_t magic;           // Magic number to verify structure
    uint32_t version;         // Protocol version

    // More fields will be added as we implement features:
    // - Memory map
    // - Framebuffer info
    // - Command line
    // - Module list
    // - ACPI/device tree
    // - etc.
};
```

```rust
// Rust version (for UEFI bootloaders)
#[repr(C)]
struct BootInfo {
    magic: u32,
    version: u32,

    // More fields to be added...
}
```
{{< /wip >}}

The `#[repr(C)]` in Rust ensures the structure layout matches C, so all bootloaders produce identical structures.

## Memory Layout

{{< wip >}}
Explain where things are loaded in memory:
- Boot sector location (BIOS)
- Stage 2 bootloader location
- Kernel loading address
- Module loading addresses
- Boot info structure location
- Page tables location

Different for each platform, but need consistency.
{{< /wip >}}

## Incremental Development

We won't implement everything at once. Here's the plan:

**Part 5 onwards - Building the bootloaders:**
Each subsequent part will add one feature to the bootloaders:
- Disk I/O and loading
- Filesystem implementation
- Config file parsing
- ELF parsing
- Memory detection
- Graphics setup
- Module loading
- Paging setup
- Final transition to kernel

As we add each feature, we'll also add the corresponding fields to the boot protocol.

## Error Handling

{{< wip >}}
How do bootloaders report errors?
- BIOS: Print to screen, halt
- UEFI: Use UEFI console services, report errors
- Error messages should be helpful for debugging
{{< /wip >}}

## Testing Strategy

{{< wip >}}
- Test each bootloader variant separately
- Verify boot protocol structure is correctly populated
- Use QEMU for all platforms
- Eventually test on real hardware
{{< /wip >}}

## Comparison with Existing Boot Protocols

Other boot protocols exist and are worth studying:

**Multiboot (1 and 2):**
- Used by GRUB
- Well-documented standard
- Our protocol will be simpler and customized for our needs

**Linux Boot Protocol:**
- x86-specific
- Very mature but complex
- Good reference for what information is needed

**Limine Protocol:**
- Modern, clean design
- Supports multiple platforms
- Worth studying for ideas

We're creating our own protocol rather than using an existing one to:
- Learn how bootloaders work
- Have full control over the process
- Customize for our specific needs
- Keep it simple and understandable

## What's Next?

In Part 5, we'll start implementing the BIOS bootloader's first stage: the 512-byte boot sector that gets everything started.
