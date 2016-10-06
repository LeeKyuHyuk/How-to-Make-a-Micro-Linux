HOSTNAME=MicroLinux
PARALLEL_JOBS=`cat /proc/cpuinfo | grep cores | wc -l `

help:
	@echo "Makefile for Building Micro Linux."
	@echo "Usage: make [ all | clean | help | run ] "
	@echo ""
	@echo

all:
	@mkdir -p tmp
	@echo "Building Kernel"
	@tar -xf packages/linux-4.8.tar.xz -C tmp
	make -C tmp/linux-4.8 mrproper
	make -C tmp/linux-4.8 defconfig
	@sed -i "s/.*CONFIG_DEFAULT_HOSTNAME.*/CONFIG_DEFAULT_HOSTNAME=\""$(HOSTNAME)"\"/" tmp/linux-4.8/.config
	make -C tmp/linux-4.8 bzImage -j $(PARALLEL_JOBS)
	@echo "Building Busybox"
	@tar -xf packages/busybox-1.25.0.tar.bz2 -C tmp
	make  -C tmp/busybox-1.25.0 clean
	make  -C tmp/busybox-1.25.0 defconfig
	@sed -i "s/.*CONFIG_STATIC.*/CONFIG_STATIC=y/" tmp/busybox-1.25.0/.config
	make  -C tmp/busybox-1.25.0 busybox -j $(PARALLEL_JOBS)
	make  -C tmp/busybox-1.25.0 install
	@echo "Building Root File System"
	@mkdir -p rootfs
	@cp -R tmp/busybox-1.25.0/_install/* rootfs
	@rm rootfs/linuxrc
	@mkdir rootfs/dev rootfs/etc rootfs/proc rootfs/root rootfs/src rootfs/sys rootfs/tmp
	@chmod 1777 rootfs/tmp
	@cp packages/rootfs/init rootfs/
	@cp packages/rootfs/etc/* rootfs/etc/
	@chmod +x rootfs/etc/bootscript.sh
	@chmod +x rootfs/etc/rc.dhcp
	@chmod +x rootfs/init
	@mkdir -p tmp/isoimage
	@cd rootfs && find . | cpio -R root:root -H newc -o | gzip > ../tmp/isoimage/rootfs.gz
	@tar -xf packages/syslinux-6.03.tar.xz -C tmp
	@cp tmp/linux-4.8/arch/x86/boot/bzImage tmp/isoimage/kernel.gz
	@cp tmp/syslinux-6.03/bios/core/isolinux.bin tmp/isoimage
	@cp tmp/syslinux-6.03/bios/com32/elflink/ldlinux/ldlinux.c32 tmp/isoimage
	@echo 'default kernel.gz initrd=rootfs.gz' > tmp/isoimage/isolinux.cfg
	@cd tmp/isoimage && genisoimage \
    -J \
    -r \
    -o ../../MicroLinux.iso \
    -b isolinux.bin \
    -c boot.cat \
    -input-charset UTF-8 \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -joliet-long \
    ./

run:
	@qemu-system-x86_64 -cdrom MicroLinux.iso

clean:
	@rm -rf tmp rootfs MicroLinux.iso

.PHONY: all clean
