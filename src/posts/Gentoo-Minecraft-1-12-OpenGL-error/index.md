---
title: "Gentoo 下 Minecraft 1.12 报 No OpenGL context found in the current thread"
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
---

## 问题

在 Gentoo 上通过 MultiMC 启动 Minecraft 1.12.2 时，客户端在初始化阶段崩溃，错误日志里能看到 `No OpenGL context found in the current thread`。

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

不过同一套环境里 Minecraft 1.16 可以正常启动，所以问题并不像是显卡驱动、Java 或 MultiMC 整体不可用。

## 修复

安装 `x11-apps/xrandr`：

```shell
# emerge -av x11-apps/xrandr
```

从堆栈看，崩溃发生在 LWJGL 2 查询显示模式时。补上 `xrandr` 后，Minecraft 1.12.2 就可以正常完成初始化。
