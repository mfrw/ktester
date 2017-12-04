PLEASE set the KDIR first for this to work.

In the makefile, after the realpath, enter the path to your linux kernel source
`KDIR=$(shell realpath ~/kp/)`

You should have qemu-system-x86 installed for x86.

When you are all set..

try :
`make boot`

then using minicom


`minicom -D /dev/pts/4`

The number may varry ...

Dependency:

build-essential
qemu-system-x86
qemu-system-arm // if you care about arm
kvm 
minicom
