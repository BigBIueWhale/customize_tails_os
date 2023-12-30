obj-m += driver1.o

KERNEL_NAME ?= $(shell uname -r)

all:
	make -C /lib/modules/$(KERNEL_NAME)/build M=$(PWD) modules

clean:
	make -C /lib/modules/$(KERNEL_NAME)/build M=$(PWD) clean
