---
title: Enabling IPv6 for Docker Containers on Debian 10
categories:
  - 网络
tags:
  - Debian
  - Docker
  - IPv6
preview: 300
date: 2021-03-19 01:34:32
comments: true
lang: en
---

## Enable IPv6 Support in Docker

For containers to listen on IPv6 interfaces, they need an IPv6 interface of their own.

See the [Docker documentation](https://docs.docker.com/config/daemon/ipv6/).

Edit `/etc/docker/daemon.json` and merge the following configuration:

```json
{
  "ipv6": true,
  "fixed-cidr-v6": "2001:db8:1::/64"
}
```

Then restart the Docker daemon:

```sh
systemctl restart docker
```

The first option enables IPv6 on the default bridge network; the second adds a subnet to the IPv6 address pool.

Note that **all** addresses in this subnet are allocated to the default global bridge network. If your docker-compose file defines custom networks that need IPv6, you must assign subnets manually, or switch to the default global bridge.

## Forward Traffic with ip6tables

After the step above, exposed container ports should be reachable over IPv6. However, for containers to access external IPv6 networks, you also need to configure ip6tables forwarding.

See [this issue](https://github.com/docker/for-linux/issues/648).

Forward traffic from the assigned subnet:

```bash
ip6tables -t nat -A POSTROUTING -s 2001:db8:1::/64 ! -o docker0 -j MASQUERADE
```

This works for now, though it doesn't feel like a complete solution.
