---
title: Notes on Flashing OpenWRT on Raspberry PI 3B+
date: 2020-05-11 00:24:30
categories:
- 网络
tags:
- Raspberry PI
- OpenWRT
comments: true
lang: en
---
## Flashing

1. RPI3B and RPI3B+ use the same firmware image, they are compatible.
2. Get a decent card reader — the image is a few hundred MB.

   > The built-in reader on my Surface stopped detecting the card after two inserts.
   >
   > My USB reader has a loose connection — constant read/write errors every few hundred KB.
3. To use the full TF card space, resizing the partition alone is not enough. Run `fsck` then `resize2fs`.
   > I resized after the first boot and it broke.
   >
   > Resizing before first boot works fine.
4. WiFi is only enabled after the first boot, when the configuration files are generated. Edit them afterwards.
5. To connect via USB-to-TTL, you need to modify `config.txt`. I never got it working — no details here.

## Configuration

1. Setting the channel to "auto" makes WiFi undetectable. Not sure why.
   * Channels 52–64 in 802.11ac require DFS/TPC ([Dynamic Frequency Selection](https://en.wikipedia.org/wiki/Dynamic_Frequency_Selection) and [Transmit Power Control](https://en.wikipedia.org/wiki/Transmit_power_control)). The Pi probably lacks support for these.
2. The WAN interface name must be **lowercase**, **lowercase**, **lowercase** — or manually assign it to the firewall `wan` zone.
3. Right after flashing, `opkg` mirrors only work over `http`, not `https` — the required packages are not yet installed.

## Networking

### Multi-WAN / Load Balancing

* Use the `mwan3` package.
* Connect an upstream router in AP mode.
* Create virtual interfaces with `ip link add link eth0 name vethX type macvlan`.
* Leave one virtual interface for `br-lan`; assign one PPPoE session to each of the rest.
* When configuring `mwan3`, **always** set a test IP so the routing policies can activate automatically.
