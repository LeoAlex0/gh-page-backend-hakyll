---
title: "Gentoo Minecraft 1.12 RuntimeException: No OpenGL context found in the current thread."
categories:
  - Gentoo
  - Fix
tags:
  - BUG
  - Minecraft
  - Gentoo
preview: 300
date: 2021-06-07 14:37:02
comments: true
lang: en
---

## Description

When launching Minecraft 1.12.2 through MultiMC on Gentoo, the client crashes during initialization with `No OpenGL context found in the current thread`.

```log
[14:37:51] [Client thread/INFO]: Setting user: zLeoAlex
[14:37:52] [Client thread/INFO]: LWJGL Version: 2.9.4
---- Minecraft Crash Report ----
// Quite honestly, I wouldn't worry myself about that.

Time: 6/7/21 2:37 PM
Description: Initializing game

java.lang.ExceptionInInitializerError
	at bib.av(SourceFile:661)
	at bib.aq(SourceFile:456)
	at bib.a(SourceFile:404)
	at net.minecraft.client.main.Main.main(SourceFile:123)
	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.lang.reflect.Method.invoke(Method.java:498)
	at org.multimc.onesix.OneSixLauncher.launchWithMainClass(OneSixLauncher.java:196)
	at org.multimc.onesix.OneSixLauncher.launch(OneSixLauncher.java:231)
	at org.multimc.EntryPoint.listen(EntryPoint.java:143)
	at org.multimc.EntryPoint.main(EntryPoint.java:34)
Caused by: java.lang.ArrayIndexOutOfBoundsException: 0
	at org.lwjgl.opengl.LinuxDisplay.getAvailableDisplayModes(LinuxDisplay.java:951)
	at org.lwjgl.opengl.LinuxDisplay.init(LinuxDisplay.java:738)
	at org.lwjgl.opengl.Display.<clinit>(Display.java:138)
	... 12 more


A detailed walkthrough of the error, its code path and all known details is as follows:
---------------------------------------------------------------------------------------

-- Head --
Thread: Client thread
Stacktrace:
	at bib.av(SourceFile:661)
	at bib.aq(SourceFile:456)

-- Initialization --
Details:
Stacktrace:
	at bib.a(SourceFile:404)
	at net.minecraft.client.main.Main.main(SourceFile:123)
	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.lang.reflect.Method.invoke(Method.java:498)
	at org.multimc.onesix.OneSixLauncher.launchWithMainClass(OneSixLauncher.java:196)
	at org.multimc.onesix.OneSixLauncher.launch(OneSixLauncher.java:231)
	at org.multimc.EntryPoint.listen(EntryPoint.java:143)
	at org.multimc.EntryPoint.main(EntryPoint.java:34)

-- System Details --
Details:
	Minecraft Version: 1.12.2
	Operating System: Linux (amd64) version 5.10.27-gentoo-x86_64
	Java Version: 1.8.0_292, Gentoo
	Java VM Version: OpenJDK 64-Bit Server VM (mixed mode), Gentoo
	Memory: 498398744 bytes (475 MB) / 649592832 bytes (619 MB) up to 7635730432 bytes (7282 MB)
	JVM Flags: 2 total; -Xms512m -Xmx8192m
	IntCache: cache: 0, tcache: 0, allocated: 0, tallocated: 0
	Launched Version: MultiMC5
	LWJGL: 2.9.4
	OpenGL: ~~ERROR~~ RuntimeException: No OpenGL context found in the current thread.
	GL Caps:
	Using VBOs: Yes
	Is Modded: Probably not. Jar signature remains and client brand is untouched.
	Type: Client (map_client.txt)
	Resource Packs:
	Current Language: ~~ERROR~~ NullPointerException: null
	Profiler Position: N/A (disabled)
	CPU: <unknown>
#@!@# Game crashed! Crash report saved to: #@!@# /home/leo/.local/share/multimc/instances/1.12.2/.minecraft/crash-reports/crash-2021-06-07_14.37.52-client.txt
```

Minecraft 1.16 can still be launched successfully in the same environment, so this does not look like a completely broken graphics driver, Java runtime, or MultiMC setup.

## Fix

Install `x11-apps/xrandr`.

```shell
# emerge -av x11-apps/xrandr
```

From the stack trace, the crash happens while LWJGL 2 is querying display modes. After installing `xrandr`, Minecraft 1.12.2 can initialize normally.
