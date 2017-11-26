#!/bin/bash

# Author : mfrw <falakreyaz@gmail.com>

case $ARCH in
	x86)
		qemu=qemu-system-i386
		;;
	x86_64)
		qemu=qemu-system-x86_64
		;;
	arm)
		qemu=qemu-system-arm
		;;
	ppc)
		qemu=qemu-system-ppc
		;;
	alpha)
		qemu=qemu-system-alpha
		;;
	mips)
		qemu=qemu-system-mips
		;;
	# Add more archs as deemed appropriate
esac

echo info chardev | nc -U -l qemu.mon | egrep -o "/dev/pts/[0-9]*" | xargs -I PTS ln -fs PTS serial.pts &

$qemu "$@" -monitor unix:qemu.mon
rm  qemu.mon
rm serial.pts
