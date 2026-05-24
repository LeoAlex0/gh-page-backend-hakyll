---
title: Raspberry PI 3B+刷OpenWRT坑点笔记
date: 2020-05-11 00:24:30
categories:
- 网络
tags:
- Raspberry PI
- OpenWRT
comments: true
---
## 刷写系统环节

1. RPI3B和RPI3B+用的同一款固件，可以通用
2. 用个稍微好一点点的读卡器吧，毕竟也有几百M

   > 我Surface上的读卡器插两次就扫不到设备了，十分蛇皮
   >
   > USB 读卡器又有点点接触不良，刷个几百k就一个读写错误，心累.jpg
3. 如果希望能完全使用TF卡的空间，单纯的resize分区是不行的，还要记得`fsck`然后跑一遍`resize2fs`
   > 不知道为什么我先配完系统之后改大小然后就崩了。
   >
   > 但是如果在第一次启动前把分区大小调好就没事。
4. `WiFi`的启用需要等到第一次启动以后，第一次启动的时候会生成配置文件，之后改改就好
5. 如果需要用`USB to TTL`之类的操作连接PI，那么还要改`config.txt`，没改成功过，不细说

## 配置环节

1. 信道填自动就搜不到`WiFi`了不知道咋回事儿
   * 802.11ac的52-64信道在国内要求DFS/TPC([动态频率选择](https://zh.wikipedia.org/wiki/DFS)和[传输功率控制](https://zh.wikipedia.org/w/index.php?title=TPC&action=edit&redlink=1))，可能是因为树莓派并没有相应的功能还往这几个信道上挤导致的。
2. `wan`的接口名一定要**小写**，一定要**小写**，一定要**小写**，或者手动修改为防火墙`wan`区域
3. 刚配好时`opkg`镜像不能用`https`，只能走`http`，因为里面套件还不全

## 网络配置

### 多拨

* 使用`mwan3`插件
* 前面接个AP模式的路由器
* 使用`ip link add link eth0 name vethX type macvlan`来添加虚拟网口
* 其中留一个虚拟网口接`br-lan`接口，其余每个一个`PPPoE`接口
* 设置`mwan3`的时候**一定**要填测试IP，让相应的策略能自动开启
