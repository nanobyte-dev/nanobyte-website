---
title: "Part 1-1: What is an operating system?"
weight: 1
---

If you've been around technology long enough, you are probably familiar with these pieces of software called operating systems: _Windows, Linux_, _MacOS_, _Android, iOS_. They are everywhere, present on almost any computer and any piece of technology that has the word _smart_ attached to it… smartphones, smart watches, smart appliances etc.

## Prerequisites

This tutorial is designed for folks with **intermediate programming experience**. If you're comfortable writing code in at least one programming language and can work through logical problems on your own, you're in good shape!

Don't worry if you haven't done low-level programming before—we'll explore OS development concepts and learn any new languages together as we build. The main thing is that you can think through problems programmatically and translate ideas into working code.

What helps to have:
- Fluency in at least one programming language
- Ability to solve logical problems through code
- Curiosity about how computers work at a lower level
- A computer to run development tools on (we'll cover setup later)

But what exactly do they do? The part we interact with the most is called the _user interface_, or the _shell_, but this is just one small part of what makes up an operating system. All of these operating systems are in fact packages consisting of many components:

<div style="max-width: 600px; margin: 2rem auto; font-family: Inter, sans-serif;">
  <table style="width: 100%; border-collapse: separate; border-spacing: 0.5rem; background: transparent; border: none;">
    <!-- User -->
    <tr>
      <td style="background: #4a90a4; color: white; text-align: center; padding: 1rem; font-weight: bold; border: 2px solid #333; border-radius: 0.25rem;">
        User
      </td>
    </tr>
    <!-- User Space -->
    <tr>
      <td style="background: #2d3a4d; color: white; padding: 0.5rem 0.5rem 1rem 0.5rem; border: 2px solid #333; border-radius: 0.25rem;">
        <div style="font-weight: bold; margin-bottom: 0.5rem;">User Space</div>
        <table style="width: 100%; border-collapse: separate; border-spacing: 0.3rem; margin: 0 auto; border: none;">
          <tr>
            <td colspan="2" style="background: #5d6a7d; color: white; text-align: center; padding: 0.8rem; border: 1px solid #333; border-radius: 0.25rem;">
              Applications
            </td>
            <td style="background: #5d6a7d; color: white; text-align: center; padding: 0.8rem; border: 1px solid #333; border-radius: 0.25rem;">
              Shell/UI
            </td>
          </tr>
          <tr>
            <td style="background: #4d5a6d; color: white; text-align: center; padding: 0.8rem; border: 1px solid #333; border-radius: 0.25rem;">
              System Services
            </td>
            <td style="background: #4d5a6d; color: white; text-align: center; padding: 0.8rem; border: 1px solid #333; border-radius: 0.25rem;">
              System Libraries
            </td>
            <td style="background: #7d6a5d; color: white; text-align: center; padding: 0.8rem; border: 1px solid #333; border-radius: 0.25rem;">
              3rd Party Libraries
            </td>
          </tr>
        </table>
      </td>
    </tr>
    <!-- Kernel Space -->
    <tr>
      <td style="background: #3a2d4d; color: white; padding: 0.5rem 0.5rem 1rem 0.5rem; border: 2px solid #333; border-radius: 0.25rem;">
        <div style="font-weight: bold; margin-bottom: 0.5rem;">Kernel Space</div>
        <table style="width: 100%; border-collapse: separate; border-spacing: 0.3rem; margin: 0 auto; border: none;">
          <tr>
            <td colspan="2" style="background: #5a4d6d; color: white; text-align: center; padding: 0.8rem; border: 1px solid #333; border-radius: 0.25rem;">
              Kernel
            </td>
            <td style="background: #5a4d6d; color: white; text-align: center; padding: 0.8rem; border: 1px solid #333; border-radius: 0.25rem;">
              Kernel Drivers
            </td>
          </tr>
        </table>
      </td>
    </tr>
    <!-- Hardware -->
    <tr>
      <td style="background: #8B4513; color: white; text-align: center; padding: 1rem; font-weight: bold; border: 2px solid #333; border-radius: 0.25rem;">
        Hardware
      </td>
    </tr>
  </table>
</div>

### Core Components

- _the kernel_ is the core component of an operating system. Its main role is to manage the hardware resources, divide them between all the different programs and users that could be using the machine. The second role is to provide _abstractions_. For example, the file system is an abstraction that hides away all the nitty gritty details about how disks and file systems work, so that programs don't need to bring their own file system implementations. Another example could be the graphics subsystem; programs can use APIs like OpenGL and DirectX (which are user-space libraries) that communicate with kernel-level graphics drivers, so individual applications don't need to directly manage GPU hardware. Something to note here is that the kernel runs using higher privileges than regular programs. Having a large kernel that does many things can make it less secure and more bloated. For this reason, many tasks are often delegated to services running in a less privileged environment where it makes sense.
- _the bootloader_ is a small component that initializes the hardware and puts the system into the state that the kernel expects (for example, switching the processor to the appropriate mode, setting up initial memory mappings), and then loads the kernel into memory and executes it
- _drivers_ are a bridge between the hardware and the kernel. Each hardware component might behave in a different, unique way; drivers allow an operating system to work across a wide variety of hardware. For example, a graphics driver translates kernel requests into commands specific to an NVIDIA or AMD GPU, while a network driver handles the specifics of different WiFi or Ethernet chips.

### System Services and Libraries

- _services_ are programs that run in the background that can serve different purposes. For example, an audio service might do the mixing between all the different sound emitting programs, and sending that audio stream to the audio card. A network service (or multiple) could take care of various networking related things, like setting up a connection when a saved Wi-Fi network is in range, or obtaining an IP address through DHCP when a network becomes active.
- _libraries_ (or _APIs_) are collections of functions that can do a lot of things. This is the main way in which programs interact with the rest of the operating system. Examples include POSIX APIs on Unix-like systems, Win32 API on Windows, or standard C library functions like `printf()` and `fopen()`.

### User-Facing Components

- _the shell_ is the main way in which users can interact with the machine. There are many different types of shells: command line, graphical, web UIs, network UIs etc.
- _programs_, every operating system comes with a collection of utilities, such as a file explorer, programs for configuring various parts of the operating system, a browser, a calculator etc.

## What are we going to build?

In this tutorial, we will build a multi-architecture operating system, starting with design decisions about which architectures and programming languages to use. We will then work on _the bootloader_ and _the kernel_, which will take up the bulk of this tutorial. The goal, by the end, is to get a simple but complete operating system with core features like a graphical interface, multitasking, file management, and basic peripheral support—providing a solid foundation that can be extended and built upon with your own design philosophies.
