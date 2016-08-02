#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/printk.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Icenowy Zheng <icenowy@aosc.xyz>");
MODULE_DESCRIPTION("A stub kernel module, only used for build testing.");
MODULE_VERSION("0.0.0");

static int __init test_mod_init(void)
{
	printk("test_mod: I'm only a testing purpose module, why do you insmod"
	       " me?");
	return 0;
}

static void __exit test_mod_exit(void)
{
	return;
}

late_initcall(test_mod_init);
module_exit(test_mod_exit);
