#include <linux/module.h>       // Needed for all modules
#include <linux/kernel.h>       // Needed for KERN_INFO

int init_module(void)
{
    printk(KERN_INFO "driver1: Hello to kernel log\n");

    // A non 0 return means init_module failed; module can't be loaded.
    return 0;
}

void cleanup_module(void)
{
    printk(KERN_INFO "driver1: Goodbye to kernel log\n");
}

MODULE_LICENSE("GPL");
