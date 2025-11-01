---
title: "Part 1: What is an operating system?"
---

If you've been around technology long enough, you are probably familiar with these pieces of software called operating systems: _Windows, Linux_, _MacOS_, _Android, iOS_. They are everywhere, present on almost any computer and any piece of technology that has the word _smart_ attached to it… smartphones, smart watches, smart appliances etc.

But what exactly do they do? The part we interact with the most is called the _user interface_, or the _shell_, but this is just one small part of what makes up an operating system. All of these operating systems are in fact packages consisting of many modules:

- _the kernel_ is the core component of an operating system. Its main role is to manage the hardware resources, divide them between all the different programs and users that could be using the machine. The second role is to provide _abstractions_. For example, the file system is an abstraction that hides away all the nitty gritty details about how disks and file systems work, so that programs don't need to bring their own file system implementations. Another example could be the graphics APIs, like OpenGL and DirectX; programs don't need to implement their own graphics drivers, all they have to do is simply call these APIs. Something to note here is that the kernel runs using higher privileges. Having a large kernel that does a lot of things could make it less secure and more bloated, so many tasks could be delegated to services running in a less privileged environment where it makes sense.
- _the bootloader_ is a small component that puts the system into the state that the kernel expects, and then loads it and executes it
- _drivers_ are a bridge between the hardware and the kernel. Each hardware component might behave in a different, unique way; drivers allow an operating system to work across a wide variety of hardware.
- _services_ are programs that run in the background that can serve different purposes. For example, an audio service might do the mixing between all the different sound emitting programs, and sending that audio stream to the audio card. A network service (or multiple) could take care of various networking related things, like setting up a connection when a saved Wi-Fi network is in range, or obtaining an IP address through DHCP when a network becomes active.
- _libraries_ (or _APIs_) are collections of functions that can do a lot of things. This is the main way in which programs interact with the rest of the operating system.
- _the shell_ is the main way in which users can interact with the machine. There are many different types of shells: command line, graphical, web UIs, network UIs etc.
- _programs_, every operating system comes with a collection of utilities, such as a file explorer, programs for configuring various parts of the operating system, a browser, a calculator etc.

## What are we going to build?

In the first part of this tutorial, we will focus on _the bootloader_, learning as much as we can about the architecture we are working with in the process. Then, we will begin working on the _kernel_, which will take up the bulk of this tutorial. The goal, by the end, is to get a basic operating system that is functionally equivalent to something like _Windows 95_.

## See also

- [Part 2: The x86 boot process]({{< ref "1-2-the-x86-boot-process" >}})
