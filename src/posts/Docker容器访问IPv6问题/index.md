---
title: Debian10配置Docker容器访问IPv6问题
categories:
  - 网络
tags:
  - Debian
  - Docker
  - IPv6
preview: 300
date: 2021-03-19 01:34:32
comments: true
---

## 打开Docker的IPv6支持

若想要容器能够监听IPv6的接口，那么首先容器内部需要自己有个IPv6的接口。

参见[docker文档](https://docs.docker.com/config/daemon/ipv6/)

修改`/etc/docker/daemon.json`，合并以下JSON配置

```json
{
  "ipv6": true,
  "fixed-cidr-v6": "2001:db8:1::/64"
}
```

然后自行`systemctl restart docker`之类重启`docker daemon`。

其中第一项会开启默认的bridge network的IPv6支持，下一个会在IPv6的地址池里添加对应的网段。

不过很奇怪的是，这一个网段的**全部**地址都会分给全局默认的bridge network，所以如果自己的docker-compose文件里有网络需要IPv6支持的，得手动分配一个网段，或者直接改用默认的全局bridge。

## 设置ip6tables转发流量

搞定上面一步之后，理论上你容器内expose出的端口都可以监听IPv6的接口了。但若是想让容器内部访问IPv6的外网，还需要配置ip6tables转发流量。

参见[这个issue](https://github.com/docker/for-linux/issues/648)

使用如下命令转发收到的对应地址的流量。

```bash
ip6tables -t nat -A POSTROUTING -s 2001:db8:1::/64 ! -o docker0 -j MASQUERADE
```

但总感觉这个方案还不够完美，只能说暂时够用了。
