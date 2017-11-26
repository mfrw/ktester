# Author: Muhammad Falak R Wani [mfrw] <falakreyaz@gmail.com>
# Date  : 2017-11-26
# Kernel Testing script


KDIR=$(shell realpath ~/kp/)

QEMU_DISPLAY?=none
ARCH?=x86

ifeq ($(ARCH), x86)
b=b
endif

ZIMAGE=$(KDIR)/arch/$(ARCH)/boot/$(b)zImage
KCONFIG=$(KDIR)/.config
YOCTO_URL=http://downloads.yoctoproject.org/releases/yocto/yocto-2.4/machines/qemu/qemu$(ARCH)
YOCTO_IMAGE=core-image-minimal-qemu$(ARCH).ext4


QEMU_OPTS = -kernel $(ZIMAGE) \
	    -enable-kvm \
	    -device virtio-serial \
	    -chardev pty,id=virtiocon0 \
	    -device virtconsole,chardev=virtiocon0 \
	    -net nic,model=virtio,vlan=0 \
	    -net tap,ifname=tap0,vlan=0,script=no,downscript=no \
	    -drive file=$(YOCTO_IMAGE),if=virtio,format=raw \
	    --append "root=/dev/vda console=hvc0" \
	    --display $(QEMU_DISPLAY) \
	    -s 

help :
	@echo "make boot For booting the kernel"
	@echo "build for building kernel"
	@echo "copy for copying ...."


boot: .modinst tap0
	ARCH=$(ARCH) qemu/qemu.sh $(QEMU_OPTS)

zImage: $(ZIMAGE)




TMPDIR := $(shell mktemp -u)
.modinst: $(ZIMAGE) $(YOCTO_IMAGE)
	mkdir $(TMPDIR)
	sudo mount -t ext4 -o loop $(YOCTO_IMAGE) $(TMPDIR)
	sudo $(MAKE) -C $(KDIR) modules_install INSTALL_MOD_PATH=$(TMPDIR)
	sudo umount $(TMPDIR)
	rmdir $(TMPDIR)
	sleep 1 && touch .modinst



$(ZIMAGE): $(KCONFIG)
	$(MAKE) -j4 -C $(KDIR)
	$(MAKE) -j4 -C $(KDIR) modules


$(KCONFIG): qemu/kernel_config.x86
	cp $^ $@
	$(MAKE) -C $(KDIR) oldnoconfig

$(YOCTO_IMAGE):
	wget $(YOCTO_URL)/$(YOCTO_IMAGE)
	sudo qemu/prepare-image.sh $(YOCTO_IMAGE)

gdb: $(ZIMAGE)
	gdb -ex "target remote localhost:1234" $(KDIR)/vmlinux

tap0:
	qemu/create_net.sh $@

clean:
	rm -f .modinst

.PHONY: clean tap0
