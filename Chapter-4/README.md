## 4장: ISO 이미지 파일 생성

`isoimage` 폴더를 생성합니다.

```bash
mkdir isoimage
```

2장에서 만든 커널을 `isoimage` 폴더로 복사합니다.
```bash
cp linux-4.8/arch/x86/boot/bzImage isoimage/kernel.gz
```

3장에서 만든 `rootfs.gz` 파일을 `isoimage` 폴더로 이동합니다.

```bash
mv rootfs.gz isoimage
```

'Syslinux'의 소스 코드를 다운로드해 압축을 해제하고 `isolinux.bin`, `ldlinux.c32` 파일을 `isoimage` 폴더로 복사합니다.

```bash
wget https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.tar.xz
tar -xf syslinux-6.03.tar.xz
cp syslinux-6.03/bios/core/isolinux.bin isoimage
cp syslinux-6.03/bios/com32/elflink/ldlinux/ldlinux.c32 isoimage
```

아래의 명령어로 ISO 이미지 파일을 생성합니다.

```bash
cd isoimage
echo 'default kernel.gz initrd=rootfs.gz' > isolinux.cfg
genisoimage \
  -J \
  -r \
  -o ../MicroLinux.iso \
  -b isolinux.bin \
  -c boot.cat \
  -input-charset UTF-8 \
  -no-emul-boot \
  -boot-load-size 4 \
  -boot-info-table \
  -joliet-long \
  ./
```
