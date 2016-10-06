## 3장: 루트 파일시스템 구축

`rootfs` 폴더를 생성하고 BusyBox를 복사한 뒤 `linuxrc` 파일을 삭제합니다.

```bash
mkdir rootfs
cp -R busybox-1.25.0/_install/* rootfs
cd rootfs
rm -f linuxrc
```

`dev`, `etc`, `proc`, `root`, `src`, `sys`, `tmp` 폴더를 생성하고 `tmp` 폴더에 권한을 부여합니다.

```bash
mkdir dev etc proc root src sys tmp
chmod 1777 tmp
```

`etc/bootscript.sh`를 생성하고 권한을 부여합니다.

```bash
cat > etc/bootscript.sh << "EOF"
#!/bin/sh
dmesg -n 1
mount -t devtmpfs none /dev
mount -t proc none /proc
mount -t sysfs none /sys

for DEVICE in /sys/class/net/* ; do
    ip link set \${DEVICE##*/} up
    [ \${DEVICE##*/} != lo ] && udhcpc -b -i \${DEVICE##*/} -s /etc/rc.dhcp
done
EOF
chmod +x etc/bootscript.sh
```

`etc/inittab`를 생성합니다.

```bash
cat > etc/inittab << "EOF"
::sysinit:/etc/bootscript.sh
::restart:/sbin/init
::ctrlaltdel:/sbin/reboot
::once:cat /etc/welcome.txt
::respawn:/bin/cttyhack /bin/sh
tty2::once:cat /etc/welcome.txt
tty2::respawn:/bin/sh
tty3::once:cat /etc/welcome.txt
tty3::respawn:/bin/sh
tty4::once:cat /etc/welcome.txt
tty4::respawn:/bin/sh
EOF
```

`etc/rc.dhcp`를 생성하고 권한을 부여합니다.

```bash
cat > etc/rc.dhcp << "EOF"
ip addr add \$ip/\$mask dev \$interface

if [ "\$router" ]; then
  ip route add default via \$router dev \$interface
fi
EOF
chmod +x etc/rc.dhcp
```

`etc/welcome.txt`를 생성합니다.

```bash
cat > etc/welcome.txt << "EOF"
####################
#    Micro Linux   #
####################
EOF
```

`init`를 생성하고 권한을 부여합니다.

```bash
cat > init << "EOF"
#!/bin/sh
exec /sbin/init
EOF
chmod +x init
```

`rootfs.gz` 파일로 루트 파일시스템을 묶어줍니다.

```bash
find . | cpio -R root:root -H newc -o | gzip > ../rootfs.gz
```
