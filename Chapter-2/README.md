## 2장: 커널과 BusyBox 빌드

### **소스코드 다운로드**

```bash
wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.8.tar.xz
wget http://busybox.net/downloads/busybox-1.25.0.tar.bz2
tar -xf linux-4.8.tar.xz
tar -xf busybox-1.25.0.tar.bz2
```

### **커널 설정**

```bash
cd linux-4.8
make mrproper
make defconfig
```

HOSTNAME을 설정합니다.

```bash
sed -i "s/.*CONFIG_DEFAULT_HOSTNAME.*/CONFIG_DEFAULT_HOSTNAME=\""$(HOSTNAME)"\"/" .config
```

### **커널 빌드**

```bash
make bzImage
```

### **BusyBox 설정**

```bash
cd busybox-1.25.0
make clean
make defconfig
sed -i "s/.*CONFIG_STATIC.*/CONFIG_STATIC=y/" .config
```

### **BusyBox 설치**

```bash
make busybox
make install
```
